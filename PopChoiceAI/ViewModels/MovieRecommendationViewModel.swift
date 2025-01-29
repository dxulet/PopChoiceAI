import Foundation

@Observable
class MovieRecommendationViewModel {
    private let aiService = AIService()
    var answer1 = ""
    var answer2 = ""
    var answer3 = ""
    var recommendation: String?
    var isLoading = false
    var error: Error?
    
    func getRecommendation() async {
        isLoading = true
        error = nil
        
        let input = "I want to watch a movie something similar to \(answer1). And I'm in the mood for something \(answer2.lowercased()). I want to watch something \(answer3.lowercased())."
        
        do {
            let embedding = try await aiService.createEmbeddings(text: input)
            let match = try await aiService.findNearestMatch(for: embedding)
            recommendation = try await aiService.getChatCompletion(initialText: input, matchedMovie: match)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
