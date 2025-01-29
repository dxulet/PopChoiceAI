import SwiftUI

struct QuestionAnswerField: View {
    let question: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.headline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.horizontal, .top])

            TextField(
                "Enter your answer",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundColor(.gray),
                axis: .vertical
            )
            .padding()
            .lineLimit(3, reservesSpace: true)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.sentences)
            .foregroundColor(.white)
            .background(Color("TextField"))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}
