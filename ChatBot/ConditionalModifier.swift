//
//  ConditionalModifier.swift
//  ChatBot
//
//  Created by LiYanan2004 on 2023/3/4.
//

import SwiftUI

extension View {
    func conditionally<V: View>(@ViewBuilder _ apply: (AnyView) -> V) -> V {
        apply(AnyView(self))
    }
}
