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
                    TextField("Type to ask ChatGPT", text: $text)
                        .textFieldStyle(.plain)
                        .bordedBackground()
                        .onSubmit {
                            chatBot.answer(text)
                            text = ""
                        }
                    if !chatBot.dialogs.isEmpty && !chatBot.generating {
                        Button(action: chatBot.regenerate) {
                            Label("Regenerate response", systemImage: "arrow.counterclockwise")
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .bordedBackground()
                        .frame(width: 40)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
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
