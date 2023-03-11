//
//  ContentView.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/2.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var chatBot: ChatBot
    @State private var text = ""
    
    var body: some View {
        let canSendMessage = chatBot.dialogs.isEmpty || chatBot.generating || !text.isEmpty
        
        ScrollViewReader { proxy in
            ScrollView {
                Group {
                    if chatBot.dialogs.isEmpty {
                        PlaceholderView()
                            #if os(macOS)
                            .focusable(false)
                            #endif
                            .environmentObject(chatBot)
                    } else {
                        VStack {
                            ForEach(chatBot.dialogs) { dialog in
                                DialogView(dialog: dialog)
                                    .id(dialog.id)
                                    .task(id: dialog.botMessage) {
                                        withAnimation { proxy.scrollTo(dialog.id, anchor: .bottom) }
                                    }
                            }
                        }
                    }
                }
                .scenePadding(.vertical)
            }
            .textSelection(.enabled)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    if #available(macOS 13.0, iOS 16, *) {
                        TextEditor(text: $text)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .padding()
                            .foregroundColor(.primary)
                            .frame(minHeight: 50, maxHeight: 150)
                            .bordedBackground()
                        Button {
                            if canSendMessage {
                                chatBot.answer(text)
                                text = ""
                            } else {
                                chatBot.regenerate()
                            }
                        } label: {
                            Image(systemName: canSendMessage ? "paperplane" : "arrow.counterclockwise")
                        }
                        .buttonStyle(.plain)
                        .labelStyle(.iconOnly)
                        .bordedBackground()
                        .frame(width: 32)
                    } else {
                        TextField("Type to ask ChatGPT", text: $text)
                            .textFieldStyle(.plain)
                            .bordedBackground()
                            .onSubmit {
                                chatBot.answer(text)
                                text = ""
                            }
                    }
                }
                .animation(.spring(), value: chatBot.dialogs.isEmpty)
                .animation(.spring(), value: chatBot.generating)
                .padding()
                .background(.background)
                .disabled(chatBot.generating)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().background(.background).environmentObject(ChatBot())
    }
}
