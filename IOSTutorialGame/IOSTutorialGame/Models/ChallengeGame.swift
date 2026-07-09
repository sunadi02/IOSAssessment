import SwiftUI

enum ChallengeGame: String, CaseIterable, Identifiable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }

    var subtitle: String {
        switch self {
        case .tapFrenzy: return "Rapid Tap Challenge"
        case .lightItUp: return "Connect the Circuit"
        case .quizRush: return "Fast General Knowledge"
        }
    }

    var icon: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush: return "brain.head.profile"
        }
    }

    static func random() -> ChallengeGame {
        allCases.randomElement() ?? .tapFrenzy
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .tapFrenzy:
            TapFrenzyView(isChallengeMode: true)
        case .lightItUp:
            LightItUpView(isChallengeMode: true)
        case .quizRush:
            QuizRushView(isChallengeMode: true)
        }
    }
}