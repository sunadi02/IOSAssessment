import Foundation
import Combine

@MainActor
final class ChallengeRouter: ObservableObject {
    static let shared = ChallengeRouter()

    @Published var activeChallenge: ChallengeGame?

    func present(_ challenge: ChallengeGame) {
        activeChallenge = challenge
    }

    func presentRandomChallenge() {
        activeChallenge = .random()
    }

    func dismiss() {
        activeChallenge = nil
    }
}
