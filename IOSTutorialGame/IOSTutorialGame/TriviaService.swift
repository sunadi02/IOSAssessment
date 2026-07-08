import Foundation

struct TriviaService {
    
    static let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!
    
    static func fetchQuestions() async throws -> [TriviaQuestion] {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        return decoded.results
    }
}
