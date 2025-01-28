//
//  ContentView.swift
//  PopChoiceAI
//
//  Created by Daulet Ashikbayev on 26.01.2025.
//

import OpenAI
import Supabase
import SwiftUI

struct ContentView: View {
    @ViewBuilder
    func QuestionAnswerField(question: String, placeholder: String, text: Binding<String>)
        -> some View
    {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.headline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.horizontal, .top])

            TextField(
                "Enter your answer",
                text: text,
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
    @State private var answer1: String = ""
    @State private var answer2: String = ""
    @State private var answer3: String = ""

    private let openai = OpenAI(apiToken: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!)
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"]!)!,
        supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_API_KEY"]!
    )

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

                QuestionAnswerField(
                    question: "What's your favorite movie and why?",
                    placeholder: "The Shawshank Redemption. Because it's a good story.",
                    text: $answer1
                )

                QuestionAnswerField(
                    question: "Are you in the mood for something new or a classic?",
                    placeholder: "I want to watch movies that were released after 1990",
                    text: $answer2
                )

                QuestionAnswerField(
                    question: "Do you wanna have fun or do you want something serious?",
                    placeholder: "I want to watch something stupid and fun",
                    text: $answer3
                )

                Button {
                    Task {
                        let input =
                            "I want to watch a movie something similar to \(answer1). And I'm in the mood for something \(answer2.lowercased()). I want to watch something \(answer3.lowercased())."
                        do {
                            let embedding = try await createEmbeddings(text: input)
                            let match = try await findNearestMatch(for: embedding)
                            
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                } label: {
                    Text("Let's go!")
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
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }

    struct MovieMatch: Decodable {
        let id: Int64
        let content: String
        let similarity: Float

        enum CodingKeys: String, CodingKey {
            case id
            case content
            case similarity
        }
    }

    struct MatchMoviesParams: Encodable {
        let query_embedding: String
        let match_threshold: Float
        let match_count: Int
        
        enum CodingKeys: String, CodingKey {
            case query_embedding
            case match_threshold
            case match_count
        }
    }

    private func createEmbeddings(text: String) async throws -> [Float] {
        let query = EmbeddingsQuery(input: .string(text), model: .textEmbeddingAda)
        do {
            let embeddings = try await openai.embeddings(query: query)
            let embedding = embeddings.data[0].embedding
            return embedding.map { Float($0) }
        } catch {
            print("Error creating embeddings: \(error)")
            throw error
        }
    }

    private func findNearestMatch(for embedding: [Float]) async throws -> String {
        let params = MatchMoviesParams(
            query_embedding: "[" + embedding.map({ String($0) }).joined(separator: ",") + "]",
            match_threshold: 0.5,
            match_count: 1
        )
        
        do {
            let response: [MovieMatch] = try await supabase
                .rpc("match_movies", params: params)
                .execute()
                .value
            let match = response.first
            
            guard let movie = match else {
                throw NSError(domain: "PopChoiceAI", code: 404, userInfo: nil)
            }
            return movie.content
        } catch {
            print("Full error:", error)
            throw error
        }
    }
}

#Preview {
    ContentView()
}
