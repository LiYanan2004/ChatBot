//
//  Conversation.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/3.
//

import Foundation

struct Conversation: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String = "New Chat"
    var dialogs: [Dialog] = []
    
    init(title: String = "New Chat", dialogs: [Dialog] = []) {
        self.title = title
        self.dialogs = dialogs
    }
}

extension Conversation: RawRepresentable, Hashable {
    var rawValue: Data {
        (try? JSONEncoder().encode(self)) ?? Data()
    }
    
    init?(rawValue: Data) {
        if let conv = try? JSONDecoder().decode(Conversation.self, from: rawValue) {
            self = conv
            return
        }
        return nil
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
