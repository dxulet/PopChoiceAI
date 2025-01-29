//
//  View+Extension.swift
//  PopChoiceAI
//
//  Created by Daulet Ashikbayev on 29.01.2025.
//

import SwiftUI

struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color("Background"))
            .font(.title)
            .fontWeight(.bold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("ButtonColor"))
            )
            .padding(32)
    }
}

extension View {
    func buttonModifier() -> some View {
        self.modifier(ButtonModifier())
    }
}
