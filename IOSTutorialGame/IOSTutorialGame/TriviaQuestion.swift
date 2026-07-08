import Foundation
internal import UIKit

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
    
    var decodedQuestion: String {
        question.htmlDecoded
    }
    
    var decodedCorrect: String {
        correctAnswer.htmlDecoded
    }
    
    func decodedAnswer(_ answer: String) -> String {
        answer.htmlDecoded
    }
}

extension String {
    var htmlDecoded: String {
        guard let data = data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let decoded = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return decoded.string
    }
}
