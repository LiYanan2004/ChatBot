//
//  ChatBot.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/2.
//

import SwiftUI
import Combine

class ChatBot: ObservableObject {
    @AppStorage("conversations") var conversations = [Conversation]()
    @Published var conversation: Conversation? {
        willSet {
            guard let newValue else { return }
            if let index = conversations.firstIndex(where: { $0.id == newValue.id }) {
                conversations[index] = newValue
            }
        }
    }
    @Published var generating = false
    var openAISever: OpenAIServer!
    var dialogs: [Dialog] {
        get { conversation?.dialogs ?? [] }
        set {
            if conversation == nil {
                switchTo(Conversation())
            }
            conversation?.dialogs = newValue
        }
    }
    
    init() {
        self.openAISever = OpenAIServer(chatBot: self)
    }
    
    func switchTo(_ conversation: Conversation?) {
        if let conversation,
           !conversations.contains(where: { $0.id == conversation.id }) {
            conversations.append(conversation)
        }
        self.conversation = conversation
        let lastDialog = conversation?.dialogs.last
        generating = lastDialog?.botMessage.isEmpty ?? false && lastDialog?.errorMsg == nil
    }
    
    func answer(_ text: String, retry: Bool = false) {
        // Create a new dialog
        if retry == false {
            dialogs.append(Dialog(userMessage: text, botMessage: ""))
        }
        self.generating = true
        
        let currentConv = conversation
        
        // Get summarized title
        Task.detached {
            if self.conversation?.title == "New Chat" {
                let title = try await self.openAISever.getTitle(message: text)
                await self.setTitle(title, conversation: currentConv)
            }
        }
        
        // Get answer from OPENAI
        Task.detached {
            let messageBody = MessageBody(dialogs: self.dialogs)
            let encoder = JSONEncoder()
            let httpBodyData = try encoder.encode(messageBody)
            do {
                let resp = try await self.openAISever.getAnswer(messagesBody: httpBodyData)
                let responsedJSON = try! JSONSerialization.jsonObject(with: resp.data(using: .utf8)!) as! [String : Any]
                guard let choice = (responsedJSON["choices"] as? [[String : Any]])?.first else {
                    guard let errorMessage = (responsedJSON["error"] as? [String : Any])?["message"] as? String else { return }
                    throw RequestError(errorMessage)
                }
                guard let message = choice["message"] as? [String : String] else { return }
                guard var content = message["content"] else { return }
                while content.hasPrefix("\n") {
                    content = String(content[content.index(after: content.startIndex)...])
                }
                await self.setBotMessage(content, conversation: currentConv)
            } catch {
                await self.dialogFailed(error.localizedDescription, conversation: currentConv)
            }
        }
    }
    
    func regenerate() {
        dialogs[dialogs.count - 1].errorMsg = nil
        dialogs[dialogs.count - 1].botMessage = ""
        answer(dialogs[dialogs.count - 1].userMessage, retry: true)
    }
    
    @MainActor func setTitle(_ title: String, conversation: Conversation?) {
        guard let conversation else { return }
        guard conversation.id == self.conversation?.id else {
            if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                conversations[index].title = title
            }
            return
        }
        self.conversation?.title = title
    }
    
    @MainActor private func setBotMessage(_ message: String, conversation: Conversation?) {
        defer {
            if conversation?.id == self.conversation?.id {
                generating = false
            }
        }
        guard let conversation else { return }
        guard conversation.id == self.conversation?.id else {
            if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                conversations[index].dialogs[conversation.dialogs.count - 1].botMessage = message
            }
            return
        }
        dialogs[dialogs.count - 1].botMessage = message
    }
    
    @MainActor private func dialogFailed(_ error: String, conversation: Conversation?) {
        defer {
            if conversation?.id == self.conversation?.id {
                generating = false
            }
        }
        guard let conversation else { return }
        guard conversation.id == self.conversation?.id else {
            if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                conversations[index].dialogs[conversation.dialogs.count - 1].errorMsg = error
            }
            return
        }
        dialogs[dialogs.count - 1].errorMsg = error
    }
    
    struct RequestError: Error, LocalizedError {
        private var error: String
        init(_ error: String) {
            self.error = error
        }
        
        var errorDescription: String? {
            error
        }
    }
}

struct Dialog: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var userMessage: String
    var botMessage: String
    var errorMsg: String?
    fileprivate var messageBody: DialogMessage {
        DialogMessage(content: userMessage)
    }
}

struct DialogMessage: Codable {
    var role: String = "user"
    var content: String
}

struct MessageBody: Codable {
    var model: String = "gpt-3.5-turbo"
    var messages: [DialogMessage]
    
    internal init(messages: [DialogMessage]) {
        self.messages = messages
    }
    
    init(dialogs: [Dialog]) {
        self = MessageBody(messages: dialogs.map({ $0.messageBody }) )
    }
}
