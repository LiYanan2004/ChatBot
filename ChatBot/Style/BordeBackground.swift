//
//  BordeBackground.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/3.
//

import SwiftUI

struct BordedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(.quaternary)
            }
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    func bordedBackground() -> some View {
        modifier(BordedBackground())
    }
}
