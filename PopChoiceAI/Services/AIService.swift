import Foundation
import OpenAI
import Supabase

class AIService {
    private let openai: OpenAI
    private let supabase: SupabaseClient
    
    init() {
        self.openai = OpenAI(apiToken: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!)
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"]!)!,
            supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_API_KEY"]!
        )
    }
    
    func createEmbeddings(text: String) async throws -> [Float] {
        let query = EmbeddingsQuery(input: .string(text), model: .textEmbeddingAda)
        let embeddings = try await openai.embeddings(query: query)
        return embeddings.data[0].embedding.map { Float($0) }
    }
    
    func findNearestMatch(for embedding: [Float]) async throws -> String {
        let params = MatchMoviesParams(
            query_embedding: "[" + embedding.map({ String($0) }).joined(separator: ",") + "]",
            match_threshold: 0.5,
            match_count: 1
        )
        
        let response: [MovieMatch] = try await supabase
            .rpc("match_movies", params: params)
            .execute()
            .value
        
        guard let movie = response.first else {
            throw NSError(domain: "PopChoiceAI", code: 404, userInfo: nil)
        }
        return movie.content
    }
    
    func getChatCompletion(initialText: String, matchedMovie: String) async throws -> String {
        var messages: [ChatQuery.ChatCompletionMessageParam] = [
            .init(
                role: .assistant,
                content: """
                You are an enthusiastic movie expert who loves recommending movies to people. You will be given two pieces of information - some context about movies and a question. Your main job is to formulate a short answer to the question using the provided context. If the answer is not given in the context, find the answer in the conversation history if possible. If you are unsure and cannot find the answer, say, "Sorry, I don't know the answer." Please do not make up the answer. Always speak as if you were chatting to a friend.
                """
            )!
        ]
        
        messages.append(
            .init(
                role: .user,
                content: "Context: \(matchedMovie) Question: \(initialText)"
            )!
        )
        let query = ChatQuery(
            messages: messages,
            model: .gpt4_o_mini,
            temperature: 0.5
        )
        
        let result = try await openai.chats(query: query)
        return result.choices.first!.message.content?.string ?? ""
    }
}
