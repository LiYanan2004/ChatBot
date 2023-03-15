//
//  DialogView.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/2.
//

import MarkdownUI
import SwiftUI

struct DialogView: View {
    var dialog: Dialog
    @State private var loading = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text(verbatim: dialog.userMessage)
                .unlimitedText()
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(.quaternary.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal)
            HStack(alignment: .top, spacing: 10) {
                VStack(spacing: 20) {
                    Image("chatgpt")
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .cornerRadius(8)
                }
                Group {
                    if let errorMsg = dialog.errorMsg {
                        Text("Error: \(errorMsg)").foregroundColor(.red)
                    } else if dialog.botMessage.isEmpty {
                        Rectangle()
                            .frame(width: 2, height: 20)
                            .opacity(loading ? 0 : 1)
                            .onAppear {
                                withAnimation(.linear(duration: 0.3).repeatForever()) {
                                    loading.toggle()
                                }
                            }
                    } else {
                        Text(verbatim: dialog.botMessage)
                            .unlimitedText()
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.green.opacity(0.3))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            DialogView(dialog: Dialog.testDialog)
        }
    }
}

extension View {
    func unlimitedText() -> some View {
        self
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension Dialog {
    static var testDialog = Dialog(userMessage: "Hello, ChatGPT", botMessage: "Hello user! I am ChatGPT, a chat bot. Today, I would like to introducing GPT-4, the next generation of GPT platform.")
}
