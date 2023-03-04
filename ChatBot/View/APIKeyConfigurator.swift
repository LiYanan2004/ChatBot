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
        VStack(alignment: .leading) {
            Text("API Key").font(.title.bold())
            TextField("Your API Key", text: $APIKEY)
            Text("You can create one at [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys)")
                .font(.callout).foregroundColor(.secondary)
        }
    }
}

struct APIKeyConfigurator_Previews: PreviewProvider {
    static var previews: some View {
        APIKeyConfigurator()
    }
}
