//
//  ChatBotApp.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/2.
//

import SwiftUI

@main
struct ChatBotApp: App {
    @State private var showAPIKeyConfigurator = false
    @StateObject private var chatBot = ChatBot()
    @Environment(\.dismiss) private var dismiss
    
    var body: some Scene {
        WindowGroup {
            Group {
                if #available(macOS 13.0, iOS 16.0, *) {
                    NavigationSplitView {
                        SideBar()
                    } detail: {
                        ContentView()
                            .navigationTitle(chatBot.conversation?.title ?? "New Chat")
                            #if !os(macOS)
                            .navigationBarTitleDisplayMode(.inline)
                            #endif
                    }
                } else {
                    NavigationView {
                        SideBar()
                        ContentView()
                            .navigationTitle(chatBot.conversation?.title ?? "New Chat")
                            #if !os(macOS)
                            .navigationBarTitleDisplayMode(.inline)
                            #endif
                    }
                }
            }
            .background()
            .environmentObject(chatBot)
        }
    }
}

extension Scene {
    func conditionally<S: Scene>(_ apply: (Self) -> S) -> S {
        apply(self)
    }
}
