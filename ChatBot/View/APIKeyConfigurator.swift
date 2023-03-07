//
//  APIKeyConfigurator.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/4.
//

import SwiftUI

struct APIKeyConfigurator: View {
    @AppStorage("api_key") private var APIKEY = ""
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, *) {
            NavigationStack {
                apiKeySection
            }
        } else {
            NavigationView {
                apiKeySection
            }
            #if !os(macOS)
            .navigationViewStyle(.stack)
            #endif
        }
    }
    
    private var apiKeySection: some View {
        VStack(alignment: .leading) {
            TextField("Your API Key", text: $APIKEY)
                #if !os(macOS)
                .textFieldStyle(.roundedBorder)
                #endif
            Text("You can create one at [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys)")
                .font(.callout).foregroundColor(.secondary)
        }
        .navigationTitle("API Key")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .scenePadding()
    }
}

struct APIKeyConfigurator_Previews: PreviewProvider {
    static var previews: some View {
        APIKeyConfigurator()
    }
}
