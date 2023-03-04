//
//  PlaceholderView.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/3.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("ChatBot via ChatGPT").font(.largeTitle.bold())
            VStack(spacing: 10) {
                Label("Examples", systemImage: "sun.max").font(.title2)
                ExampleButtons(text: "Explain quantum computing in simple terms")
                ExampleButtons(text: "Got any creative ideas for a 10 year old's birthday?")
                ExampleButtons(text: "How do I make an HTTP request in Javascript?")
            }
            VStack(spacing: 10) {
                Label("Capabilities", systemImage: "bolt").font(.title2)
                Text("Remembers what user said earlier in the conversation")
                    .bordedBackground()
                Text("Allows user to provide follow-up corrections")
                    .bordedBackground()
                Text("Trained to decline inappropriate requests")
                    .bordedBackground()
            }
            VStack(spacing: 10) {
                Label("Limitations", systemImage: "exclamationmark.triangle").font(.title2)
                Text("May occasionally generate incorrect information")
                    .bordedBackground()
                Text("May occasionally produce harmful instructions or biased content")
                    .bordedBackground()
                Text("Limited knowledge of world and events after 2021")
                    .bordedBackground()
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 380)
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct ExampleButtons: View {
    var text: String
    @EnvironmentObject private var chatBot: ChatBot
    var body: some View {
        Button("\"" + text + "\" →") {
            chatBot.answer(text)
        }
        .buttonStyle(.plain)
        .bordedBackground()
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            PlaceholderView()
        }
    }
}
