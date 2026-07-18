import SwiftUI

struct LeaderboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var store = SessionStore.shared
    @State private var selectedMode: GameMode = .tapFrenzy
    private let modes: [GameMode] = [.tapFrenzy, .lightItUp, .quizRush]

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        sectionLabel("Select a game")
                        modePicker
                        sectionLabel("Top scores")
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
        PlayzoBackground(colorScheme: colorScheme)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Playzo Leaderboard")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.12, green: 0.22, blue: 0.43))
            Text("See the top runs for each game.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.12, green: 0.22, blue: 0.43))
        }
        .padding(.top, 22)
    }

    private var modePicker: some View {
        Picker("Game mode", selection: $selectedMode) {
            ForEach(modes, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var selectedSessions: [GameSession] {
        store.leaderboard(for: selectedMode, limit: 10)
    }

    private var leaderboardCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedMode.rawValue)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(primaryTextColor)
                    Text("Leaderboard for the selected game")
                        .font(.system(size: 13))
                        .foregroundColor(secondaryTextColor)
                }
                Spacer()
                Image(systemName: modeIcon(selectedMode))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(modeColor(selectedMode))
                    .frame(width: 42, height: 42)
                    .background(modeColor(selectedMode).opacity(colorScheme == .dark ? 0.22 : 0.12))
                    .cornerRadius(14)
            }

            if selectedSessions.isEmpty {
                emptyStateCard(title: "No \(selectedMode.rawValue) scores yet", subtitle: "Play a round and your best runs will appear here.")
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(selectedSessions.enumerated()), id: \.element.id) { index, session in
                        row(session, rank: index + 1)
                    }
                }
            }
        }
        .padding(18)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(cardStroke, lineWidth: 1)
        )
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.28 : 0.12), radius: 14, x: 0, y: 8)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(1.2)
            .foregroundColor(secondaryTextColor)
            .padding(.horizontal, 4)
    }

    private func row(_ session: GameSession, rank: Int?) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(modeColor(session.mode).opacity(0.18))
                    .frame(width: 42, height: 42)
                Text(rank.map { "\($0)" } ?? initials(for: session.playerName))
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

    private var cardBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }

    private var cardStroke: Color {
        Color(uiColor: .tertiarySystemFill)
    }

    private var primaryTextColor: Color {
        Color(uiColor: .label)
    }

    private var secondaryTextColor: Color {
        Color(uiColor: .secondaryLabel)
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

    private func modeIcon(_ mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush: return "brain.head.profile"
        }
    }
}
