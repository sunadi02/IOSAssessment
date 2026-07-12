import SwiftUI

struct LeaderboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var store = SessionStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        leaderboardCard
                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(red: 0.04, green: 0.05, blue: 0.08), Color(red: 0.08, green: 0.09, blue: 0.14), Color(red: 0.06, green: 0.07, blue: 0.10)]
                    : [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color(red: 0.16, green: 0.72, blue: 0.56).opacity(0.18), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 340
            )
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Playzo Leaderboard")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.12, green: 0.22, blue: 0.43))
            Text("See the top runs across all games.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.12, green: 0.22, blue: 0.43))
        }
        .padding(.top, 22)
    }

    private var leaderboardCard: some View {
        VStack(spacing: 10) {
            if store.leaderboard().isEmpty {
                emptyStateCard(title: "No leaderboard yet", subtitle: "Play a round and your best runs will appear here.")
            } else {
                VStack(spacing: 10) {
                    ForEach(store.leaderboard(limit: 20)) { session in
                        row(session)
                    }
                }
            }
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(uiColor: .separator), lineWidth: 1)
        )
        .cornerRadius(22)
        .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private func row(_ session: GameSession) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(modeColor(session.mode).opacity(0.18))
                    .frame(width: 42, height: 42)
                Text(initials(for: session.playerName))
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(modeColor(session.mode))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(session.playerName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color(uiColor: .label))
                Text(session.mode.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(session.score)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(uiColor: .label))
                Text(session.timestamp, style: .relative)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
        }
        .padding(14)
        .background(Color(uiColor: .tertiarySystemBackground))
        .cornerRadius(16)
    }

    private func emptyStateCard(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color(uiColor: .label))
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(uiColor: .tertiarySystemBackground))
        .cornerRadius(16)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let string = String(letters)
        return string.isEmpty ? "S" : string.uppercased()
    }

    private func modeColor(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color(red: 0.10, green: 0.45, blue: 0.96)
        case .lightItUp: return Color(red: 0.62, green: 0.28, blue: 0.92)
        case .quizRush: return Color(red: 0.16, green: 0.72, blue: 0.56)
        }
    }
}
