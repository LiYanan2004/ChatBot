//
//  OpenAIServer.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/4.
//

import SwiftUI

actor OpenAIServer {
    @AppStorage("api_key") private var APIKEY = ""
    unowned let chatBot: ChatBot
    
    init(chatBot: ChatBot) {
        self.chatBot = chatBot
    }
    
    nonisolated func getAnswer(messagesBody: Data) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(await APIKEY)",
            "Content-Type": "application/json"
        ]
        request.httpBody = messagesBody
        let (data, _) = try await URLSession.shared.data(for: request)
        return String(data: data, encoding: .utf8)!
            .replacingOccurrences(of: "\\\\n", with: "@@@@@@@@@@")
            .replacingOccurrences(of: "\\\\r", with: "@@@@@@@@@@")
            .replacingOccurrences(of: "\\\\t", with: "@@@@@")
    }
    
    nonisolated func getTitle(message: String) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(await APIKEY)",
            "Content-Type": "application/json"
        ]
        let encoder = JSONEncoder()
        let message = Dialog(userMessage: "Shorten the following sentence and turn it into a statement: '\(message)'.", botMessage: "")
        request.httpBody = try encoder.encode(MessageBody(dialogs: [message]))
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = String(data: data, encoding: .utf8)!
            .replacingOccurrences(of: "\\\\n", with: "@@@@@@@@@@")
            .replacingOccurrences(of: "\\\\r", with: "@@@@@@@@@@")
            .replacingOccurrences(of: "\\\\t", with: "@@@@@")
        let responsedJSON = try! JSONSerialization.jsonObject(with: response.data(using: .utf8)!) as! [String : Any]
        if let choice = (responsedJSON["choices"] as? [[String : Any]])?.first,
           let message = choice["message"] as? [String : String],
           var content = message["content"] {
            while content.hasPrefix("\n") {
                content = String(content[content.index(after: content.startIndex)...])
            }
            return content
        }
        
        throw URLError(.cannotParseResponse)
    }
}
