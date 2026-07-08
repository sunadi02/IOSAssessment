import Foundation

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Identifiable {
    let id = UUID()
    let category: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
    
    // use these everywhere in the view instead of the raw properties
    var decodedQuestion: String { question.htmlDecoded }
    var decodedCorrect: String { correctAnswer.htmlDecoded }
}

extension String {
    var htmlDecoded: String {
        var result = self
        let replacements: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#039;": "'",
            "&lrm;": "",
            "&ndash;": "–",
            "&mdash;": "—",
            "&rsquo;": "'",
            "&ldquo;": "\u{201C}",
            "&rdquo;": "\u{201D}"
        ]
        for (entity, char) in replacements {
            result = result.replacingOccurrences(of: entity, with: char)
        }
        return result
    }
}
