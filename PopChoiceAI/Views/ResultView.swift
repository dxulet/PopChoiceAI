//
//  ResultView.swift
//  PopChoiceAI
//
//  Created by Daulet Ashikbayev on 29.01.2025.
//

import SwiftUI

struct ResultView: View {
    @Binding var result: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                Text("PopChoice")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                if let result {
                    let title = result.components(separatedBy: "\n").first
                    let description = result.components(separatedBy: "\n").last
                    Text(title ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    if description != "Sorry, I don't know the answer." {
                        Text(description ?? "")
                            .font(.title3)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                }
                // button start over
                Button {
                    result = nil
                    dismiss()
                } label: {
                    Text("Go Again")
                        .buttonModifier()
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
    }
}

#Preview {
    ResultView(result: .constant("The Shawshank Redemption"))
}
