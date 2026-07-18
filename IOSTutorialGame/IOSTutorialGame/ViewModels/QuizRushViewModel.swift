import Foundation
import SwiftUI
import Combine

enum QuizState {
    case ready
    case loading
    case loaded
    case failed
    case finished
}

enum QuizDifficulty: String, CaseIterable, Identifiable {
    case any = "Any"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }

    var queryValue: String? {
        self == .any ? nil : rawValue.lowercased()
    }
}

enum QuizCategory: String, CaseIterable, Identifiable {
    case any = "Any"
    case general = "General"
    case science = "Science"
    case history = "History"
    case sports = "Sports"
    case geography = "Geography"

    var id: Int? {
        switch self {
        case .any: return nil
        case .general: return 9
        case .science: return 17
        case .history: return 23
        case .sports: return 21
        case .geography: return 22
        }
    }
}

@MainActor
class QuizRushViewModel: ObservableObject {
    private let persistResults: Bool
    
    @AppStorage("quizHighScore") var highScore = 0
    @AppStorage("playerName") var playerName = "Player"
    
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var bestStreak = 0
    @Published var state: QuizState = .ready
    @Published var selectedAnswer: String? = nil
    @Published var timeLeft = 15
    @Published var errorMessage = ""
    @Published var selectedDifficulty: QuizDifficulty = .any
    @Published var selectedCategory: QuizCategory = .any
    
    private var answerChoicesByQuestionID: [UUID: [String]] = [:]
    private var timer: Timer?

    init(persistResults: Bool = true) {
        self.persistResults = persistResults
    }
    
    var current: TriviaQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var progress: String {
        "\(currentIndex + 1) of \(questions.count)"
    }
    
    func load() async {
        state = .loading
        selectedAnswer = nil
        currentIndex = 0
        score = 0
        streak = 0
        bestStreak = 0
        answerChoicesByQuestionID = [:]
        
        do {
            questions = try await TriviaService.fetchQuestions(difficulty: selectedDifficulty, category: selectedCategory)
            answerChoicesByQuestionID = Dictionary(
                uniqueKeysWithValues: questions.map { question in
                    (question.id, (question.incorrectAnswers + [question.correctAnswer]).shuffled())
                }
            )
            state = .loaded
            startTimer()
        } catch {
            errorMessage = "couldn't load questions. check your connection."
            state = .failed
        }
    }

    func resetToMenu() {
        timer?.invalidate()
        state = .ready
        selectedAnswer = nil
        currentIndex = 0
        score = 0
        streak = 0
        bestStreak = 0
        timeLeft = 15
        questions = []
        answerChoicesByQuestionID = [:]
    }
    
    func answer(_ choice: String) {
        guard selectedAnswer == nil, let q = current else { return }
        selectedAnswer = choice
        timer?.invalidate()
        
        if choice == q.decodedCorrect {
            streak += 1
            bestStreak = max(bestStreak, streak)
            let bonus = streak >= 3 ? 2 : 1
            score += 10 * bonus
        } else {
            streak = 0
            score = max(0, score - 3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.nextQuestion()
        }
    }
    
    func nextQuestion() {
        if currentIndex + 1 >= questions.count {
            if persistResults {
                if score > highScore { highScore = score }
                let loc = LocationService.shared.coordinate
                SessionStore.shared.save(GameSession(mode: .quizRush, score: score, playerName: playerName, latitude: loc.lat, longitude: loc.lon))
            }
            state = .finished
        } else {
            currentIndex += 1
            selectedAnswer = nil
            timeLeft = 15
            startTimer()
        }
    }
    
    func startTimer() {
        timeLeft = 15
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.timeLeft > 0 {
                    self.timeLeft -= 1
                } else {
                    self.timer?.invalidate()
                    self.streak = 0
                    self.selectedAnswer = "timeout"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.nextQuestion()
                    }
                }
            }
        }
    }

    func answerChoices(for question: TriviaQuestion) -> [String] {
        answerChoicesByQuestionID[question.id] ?? (question.incorrectAnswers + [question.correctAnswer])
    }
    
    func difficultyColor(_ d: String) -> Color {
        switch d {
        case "easy": return .green
        case "medium": return .orange
        default: return .red
        }
    }
}
