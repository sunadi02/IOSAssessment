import Foundation

struct TriviaService {
    
    static func fetchQuestions(difficulty: QuizDifficulty = .any, category: QuizCategory = .any) async throws -> [TriviaQuestion] {
        var components = URLComponents(string: "https://opentdb.com/api.php")!
        var items = [
            URLQueryItem(name: "amount", value: "10"),
            URLQueryItem(name: "type", value: "multiple")
        ]
        if let difficultyValue = difficulty.queryValue {
            items.append(URLQueryItem(name: "difficulty", value: difficultyValue))
        }
        if let categoryID = category.id {
            items.append(URLQueryItem(name: "category", value: "\(categoryID)"))
        }
        components.queryItems = items

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        return decoded.results
    }
}
