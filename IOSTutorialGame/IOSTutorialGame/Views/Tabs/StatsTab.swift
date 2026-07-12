import SwiftUI
import Charts

struct StatsTab: View {
    @ObservedObject private var store = SessionStore.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedMode: GameMode = .tapFrenzy

    private let modes: [GameMode] = [.tapFrenzy, .lightItUp, .quizRush]
    
    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        sectionLabel("Select a game")
                        modePicker

                        selectedStatsCard

                        sectionLabel("Combined history")
                        chartCard

                        sectionLabel("Recent runs")
                        recentCard

                        Spacer(minLength: 28)
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
                colors: colorScheme == .dark ? [Color(red: 0.04, green: 0.05, blue: 0.08), Color(red: 0.08, green: 0.09, blue: 0.14)] : [Color(uiColor: .systemBackground), Color(uiColor: .secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color(red: 0.62, green: 0.78, blue: 1.0).opacity(0.12), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 340
            )
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Playzo Stats")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.12, green: 0.22, blue: 0.43))
                    .shadow(color: Color(red: 0.10, green: 0.45, blue: 0.96).opacity(colorScheme == .dark ? 0.25 : 0.5), radius: 6, x: 0, y: 0)
                Text("Track performance, recent runs, and leaderboard position.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.72) : Color(red: 0.34, green: 0.42, blue: 0.56))
            }
            Spacer()
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
        store.sessions
            .filter { $0.mode == selectedMode }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private var selectedStatsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedMode.rawValue)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(primaryTextColor)
                    Text("Statistics for the selected game")
                        .font(.system(size: 13))
                        .foregroundColor(secondaryTextColor)
                }
                Spacer()
                Image(systemName: selectedIcon(for: selectedMode))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(modeColor(selectedMode))
                    .frame(width: 42, height: 42)
                    .background(modeColor(selectedMode).opacity(colorScheme == .dark ? 0.22 : 0.12))
                    .cornerRadius(14)
            }

            HStack(spacing: 10) {
                statChip(title: "Best", value: "\(store.best(for: selectedMode))")
                statChip(title: "Plays", value: "\(selectedSessions.count)")
                statChip(title: "Avg", value: "\(averageScore(for: selectedSessions))")
            }

            if selectedSessions.isEmpty {
                emptyStateCard(title: "No runs yet", subtitle: "Play this game once to unlock the selected section.")
            } else {
                VStack(spacing: 10) {
                    ForEach(selectedSessions.prefix(4)) { session in
                        recentRow(session)
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

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if store.sessions.isEmpty {
                emptyStateCard(title: "No score history yet", subtitle: "The chart will fill once games are finished.")
            } else {
                Chart(store.recent(40)) { session in
                    LineMark(
                        x: .value("Time", session.timestamp),
                        y: .value("Score", session.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(by: .value("Game", session.mode.rawValue))

                    PointMark(
                        x: .value("Time", session.timestamp),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(by: .value("Game", session.mode.rawValue))
                }
                .frame(height: 180)
                .chartForegroundStyleScale([
                    GameMode.tapFrenzy.rawValue: Color(red: 0.10, green: 0.45, blue: 0.96),
                    GameMode.lightItUp.rawValue: Color(red: 0.62, green: 0.28, blue: 0.92),
                    GameMode.quizRush.rawValue: Color(red: 0.16, green: 0.72, blue: 0.56)
                ])
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartLegend(position: .bottom, alignment: .leading)
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

    private var recentCard: some View {
        VStack(spacing: 10) {
            if selectedSessions.isEmpty {
                emptyStateCard(title: "No games played yet", subtitle: "Finish a round to populate recent history.")
            } else {
                VStack(spacing: 10) {
                    ForEach(selectedSessions.prefix(8)) { session in
                        recentRow(session)
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

    private func statChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.0)
                .foregroundColor(secondaryTextColor)
            Text(value)
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundColor(primaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(uiColor: .tertiarySystemBackground))
        .cornerRadius(16)
    }

    func bestRow(mode: GameMode, icon: String, accent: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(accent)
                .cornerRadius(10)
            
            Text(mode.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(primaryTextColor)
            
            Spacer()
            
            Text("\(store.best(for: mode))")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(primaryTextColor)
        }
        .padding(14)
        .background(cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardStroke, lineWidth: 1)
        )
    }
    
    func recentRow(_ session: GameSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(session.playerName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                Text(session.mode.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(secondaryTextColor)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(session.score) pts")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(primaryTextColor)
                Text(session.timestamp, style: .relative)
                    .font(.system(size: 11))
                    .foregroundColor(secondaryTextColor)
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
                .foregroundColor(primaryTextColor)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(secondaryTextColor)
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

    private func selectedIcon(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush: return "questionmark.bubble.fill"
        }
    }

    private func averageScore(for sessions: [GameSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return sessions.map(\.score).reduce(0, +) / sessions.count
    }

    func modeColor(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color(red: 0.10, green: 0.45, blue: 0.96)
        case .lightItUp: return Color(red: 0.62, green: 0.28, blue: 0.92)
        case .quizRush: return Color(red: 0.16, green: 0.72, blue: 0.56)
        }
    }
}
