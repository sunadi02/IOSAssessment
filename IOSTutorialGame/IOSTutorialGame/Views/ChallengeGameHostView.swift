import SwiftUI

struct ChallengeGameHostView: View {
    let game: ChallengeGame

    var body: some View {
        NavigationStack {
            game.destination
        }
    }
}