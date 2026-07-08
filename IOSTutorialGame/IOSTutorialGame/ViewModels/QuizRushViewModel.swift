import Foundation
import SwiftUI
import Combine

enum QuizState {
    case loading
    case loaded
    case failed
    case finished
}

@MainActor
class QuizRushViewModel: ObservableObject {
    
    @AppStorage("quizHighScore") var highScore = 0
    @AppStorage("playerName") var playerName = "Player"
    
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var bestStreak = 0
    @Published var state: QuizState = .loading
    @Published var selectedAnswer: String? = nil
    @Published var timeLeft = 15
    @Published var errorMessage = ""
    
    private var timer: Timer?
    
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
        
        do {
            questions = try await TriviaService.fetchQuestions()
            state = .loaded
            startTimer()
        } catch {
            errorMessage = "couldn't load questions. check your connection."
            state = .failed
        }
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
            if score > highScore { highScore = score }
            let loc = LocationService.shared.coordinate
            SessionStore.shared.save(GameSession(mode: .quizRush, score: score, playerName: playerName, latitude: loc.lat, longitude: loc.lon))
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
    
    func difficultyColor(_ d: String) -> Color {
        switch d {
        case "easy": return .green
        case "medium": return .orange
        default: return .red
        }
    }
}
