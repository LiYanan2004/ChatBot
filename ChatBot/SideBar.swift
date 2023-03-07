//
//  SideBar.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/4.
//

import SwiftUI

struct SideBar: View {
    @AppStorage("api_key") private var APIKEY = ""
    @AppStorage("firstOpen") private var firstOpen = true
    @EnvironmentObject private var chatBot: ChatBot
    @State private var showConfirmDialog = false
    @State private var showAPIKeyPopover = false
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    private var isCompact: Bool {
        #if !os(macOS)
        horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    var body: some View {
        conversationList
            .navigationTitle("Conversations")
            .safeAreaInset(edge: .bottom) {
                if !isCompact {
                    VStack {
                        newChatButton
                        clearConversationsButton
                    }
                    .buttonStyle(.plain)
                    .scenePadding()
                }
            }
            .listStyle(.sidebar)
            .conditionally {
                if #available(macOS 13.0, iOS 16.0, *) {
                    $0.navigationSplitViewColumnWidth(min: 230, ideal: 400)
                } else {
                    $0
                }
            }
            .toolbar(content: toolbarContent)
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem {
            Button {
                showAPIKeyPopover = true
            } label: {
                Label("API Key", systemImage: "key.fill")
            }
            .popover(isPresented: $showAPIKeyPopover, arrowEdge: .bottom) {
                APIKeyConfigurator()
                    .frame(idealWidth: 380, idealHeight: 200)
            }
            .onAppear {
                if firstOpen {
                    showAPIKeyPopover = true
                    firstOpen = false
                }
            }
        }
        
        #if !os(macOS)
        ToolbarItemGroup(placement: .bottomBar) {
            if isCompact {
                clearConversationsButton
                Spacer()
                newChatButton
            }
        }
        #endif
    }
    
    @ViewBuilder
    var conversationList: some View {
        let currentConversationID = Binding<UUID?> {
            chatBot.conversation?.id
        } set: { id in
            if let index = chatBot.conversations.firstIndex(where: { $0.id == id }) {
                chatBot.switchTo(chatBot.conversations[index])
            }
        }
        if #available(macOS 13.0, iOS 16.0, *) {
            List(chatBot.conversations, selection: currentConversationID) { conversation in
                NavigationLink(conversation.title, value: conversation.id)
                    .swipeActions { deleteButton(conversation) }
            }
        } else {
            List(chatBot.conversations) { conversation in
                NavigationLink(
                    conversation.title,
                    tag: conversation.id,
                    selection: currentConversationID
                ) {
                    ContentView()
                        .navigationTitle(chatBot.conversation?.title ?? "New Chat")
                        #if !os(macOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                }
                .swipeActions { deleteButton(conversation) }
            }
        }
    }
    
    func deleteButton(_ conversation: Conversation) -> some View {
        Button(role: .destructive) {
            if let index = chatBot.conversations.firstIndex(of: conversation) {
                chatBot.conversations.remove(at: index)
                chatBot.switchTo(nil)
            }
        } label: {
            Label("Delete Conversation", systemImage: "trash")
        }
    }
    
    var newChatButton: some View {
        Button {
            let conv = Conversation()
            chatBot.switchTo(conv)
        } label: {
            Label("New Chat", systemImage: "plus")
        }
        #if os(macOS)
        .bordedBackground()
        #endif
    }
    
    @ViewBuilder
    var clearConversationsButton: some View {
        if !chatBot.conversations.isEmpty {
            Button {
                showConfirmDialog = true
            } label: {
                Label("Clear Conversations", systemImage: "trash")
            }
            .foregroundColor(.red)
            #if os(macOS)
            .bordedBackground()
            #endif
            .confirmationDialog("Clear Conversations", isPresented: $showConfirmDialog) {
                Button("Clear", role: .destructive) {
                    chatBot.conversations = []
                    chatBot.switchTo(nil)
                }
            } message: {
                Text("This action can't redo")
            }
        }
    }
}

struct SideBar_Previews: PreviewProvider {
    static var previews: some View {
        if #available(macOS 13.0, iOS 16.0, *) {
            NavigationStack {
                SideBar()
                    .frame(width: 230)
                    .environmentObject(ChatBot())
            }
        }
    }
}
