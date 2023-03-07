//
//  SideBar.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/4.
//

import SwiftUI

struct SideBar: View {
    @EnvironmentObject private var chatBot: ChatBot
    @State private var showConfirmDialog = false
    @State private var showAPIKeyPopover = false
    
    var body: some View {
        conversationList
            .navigationTitle("Conversations")
            .safeAreaInset(edge: .bottom) {
                VStack {
                    newChatButton
                    clearConversationsButton
                }
                .buttonStyle(.plain)
                .scenePadding()
            }
            .listStyle(.sidebar)
            .conditionally {
                if #available(macOS 13.0, *) {
                    $0.navigationSplitViewColumnWidth(min: 230, ideal: 400)
                } else {
                    $0
                }
            }
            .toolbar {
                Button {
                    showAPIKeyPopover = true
                } label: {
                    Label("API Key", systemImage: "key.fill")
                }
                .popover(isPresented: $showAPIKeyPopover) {
                    APIKeyConfigurator().padding()
                }
            }
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
        if #available(macOS 13.0, *) {
            List(chatBot.conversations, selection: currentConversationID) { conversation in
                NavigationLink(conversation.title, value: conversation.id)
                    .contextMenu { deleteButton(conversation) }
            }
        } else {
            List(chatBot.conversations) { conversation in
                NavigationLink(
                    conversation.title,
                    tag: conversation.id,
                    selection: currentConversationID
                ) {
                    ContentView().navigationTitle(chatBot.conversation?.title ?? "New Chat")
                }
                .contextMenu { deleteButton(conversation) }
            }
        }
    }
    
    func deleteButton(_ conversation: Conversation) -> some View {
        Button("Delete Conversation") {
            if let index = chatBot.conversations.firstIndex(of: conversation) {
                chatBot.conversations.remove(at: index)
                chatBot.switchTo(nil)
            }
        }
    }
    
    var newChatButton: some View {
        Button {
            let conv = Conversation()
            chatBot.switchTo(conv)
        } label: {
            Label("New Chat", systemImage: "plus")
        }
        .bordedBackground()
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
            .bordedBackground()
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
        if #available(macOS 13.0, *) {
            NavigationStack {
                SideBar()
                    .frame(width: 230)
                    .environmentObject(ChatBot())
            }
        }
    }
}
