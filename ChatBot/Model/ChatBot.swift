//
//  ChatBot.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/2.
//

import SwiftUI

class ChatBot: ObservableObject {
    @Published var conversation = Conversation()
    @Published var generating = false
    var openAISever: OpenAIServer!
    var dialogs: [Dialog] {
        get { conversation.dialogs }
        set { conversation.dialogs = newValue }
    }
    
    init() {
        self.openAISever = OpenAIServer(chatBot: self)
    }
    
    func switchTo(_ conversation: Conversation) {
        self.conversation = conversation
        generating = false
    }
    
    func answer(_ text: String, retry: Bool = false) {
        // Create a new dialog
        if retry == false {
            dialogs.append(Dialog(userMessage: text, botMessage: ""))
        }
        self.generating = true
        
        // Get summarized title
        Task.detached {
            if self.conversation.title == "New Chat" {
                try await self.generateTitle(from: text)
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
                guard let choice = (responsedJSON["choices"] as? [[String : Any]])?.first else { return }
                guard let message = choice["message"] as? [String : String] else { return }
                guard let content = message["content"] else { return }
                await self.setBotMessage(String(content.trimmingPrefix(while: { $0.isWhitespace })))
            } catch {
                await self.dialogFailed(error.localizedDescription)
            }
        }
    }
    
    func regenerate() {
        dialogs[dialogs.count - 1].errorMsg = nil
        dialogs[dialogs.count - 1].botMessage = ""
        answer(dialogs[dialogs.count - 1].userMessage, retry: true)
    }
    
    private func generateTitle(from message: String) async throws {
        let title = try await openAISever.getTitle(message: message)
        await setTitle(title)
    }
    
    @MainActor private func setTitle(_ title: String) {
        conversation.title = title
    }
    
    @MainActor private func setBotMessage(_ message: String) {
        dialogs[dialogs.count - 1].botMessage = message
        generating = false
    }
    
    @MainActor private func dialogFailed(_ error: String) {
        dialogs[dialogs.count - 1].errorMsg = error
        generating = false
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
