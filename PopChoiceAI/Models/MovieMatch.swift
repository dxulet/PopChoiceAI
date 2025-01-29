import Foundation

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
