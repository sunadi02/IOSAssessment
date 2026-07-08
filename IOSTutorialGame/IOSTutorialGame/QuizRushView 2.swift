import SwiftUI

struct QuizRushView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("QUIZ RUSH")
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(.white)
                Text("Coming soon…")
                    .font(.subheadline)
                    .foregroundColor(Color(white: 0.6))
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
