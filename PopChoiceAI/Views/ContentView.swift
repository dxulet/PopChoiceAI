import SwiftUI

struct ContentView: View {
    @State private var viewModel = MovieRecommendationViewModel()
    @State private var showResult = false
    
    var body: some View {
        NavigationStack {
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

                    QuestionAnswerField(
                        question: "What's your favorite movie and why?",
                        placeholder: "The Shawshank Redemption. Because it's a good story.",
                        text: $viewModel.answer1
                    )

                    QuestionAnswerField(
                        question: "Are you in the mood for something new or a classic?",
                        placeholder: "I want to watch movies that were released after 1990",
                        text: $viewModel.answer2
                    )

                    QuestionAnswerField(
                        question: "Do you wanna have fun or do you want something serious?",
                        placeholder: "I want to watch something stupid and fun",
                        text: $viewModel.answer3
                    )

                    Button {
                        Task {
                            await viewModel.getRecommendation()
                            showResult = true
                        }
                    } label: {
                        Text("Let's go!")
                            .buttonModifier()
                    }
                    .buttonStyle(.plain)
                    .opacity(viewModel.isLoading ? 0.5 : 1)
                    .disabled(viewModel.isLoading)
                    Spacer()
                }
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .scaleEffect(1.5)
                }
            }
            .navigationDestination(isPresented: $showResult) {
                ResultView(result: $viewModel.recommendation)
            }
        }
    }
}
