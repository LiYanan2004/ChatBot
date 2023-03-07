//
//  ChatBotApp.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/2.
//

import SwiftUI

@main
struct ChatBotApp: App {
    @AppStorage("api_key") private var APIKEY = ""
    @AppStorage("firstOpen") private var firstOpen = true
    @State private var showAPIKeyConfigurator = false
    @StateObject private var chatBot = ChatBot()
    @Environment(\.dismiss) private var dismiss
    
    var body: some Scene {
        WindowGroup {
            Group {
                if #available(macOS 13.0, *) {
                    NavigationSplitView {
                        SideBar()
                    } detail: {
                        ContentView()
                            .navigationTitle(chatBot.conversation?.title ?? "New Chat")
                    }
                } else {
                    NavigationView {
                        SideBar()
                        ContentView()
                            .navigationTitle(chatBot.conversation?.title ?? "New Chat")
                    }
                }
            }
            .background()
            .environmentObject(chatBot)
            .onAppear {
                if firstOpen {
                    showAPIKeyConfigurator = true
                    firstOpen = false
                }
            }
            .sheet(isPresented: $showAPIKeyConfigurator) {
                VStack(alignment: .trailing) {
                    APIKeyConfigurator()
                    Button(APIKEY.isEmpty ? "Set it later" : "OK", action: { showAPIKeyConfigurator = false })
                }
                .frame(minWidth: 300)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

extension Scene {
    func conditionally<S: Scene>(_ apply: (Self) -> S) -> S {
        apply(self)
    }
}
