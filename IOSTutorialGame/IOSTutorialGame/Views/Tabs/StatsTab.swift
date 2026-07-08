import SwiftUI
import Charts

struct StatsTab: View {
    @ObservedObject private var store = SessionStore.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        sectionLabel("Leaderboard")
                        leaderboardCard

                        sectionLabel("Personal Bests")
                        VStack(spacing: 12) {
                            bestRow(mode: .tapFrenzy, icon: "hand.tap.fill", accent: Color(red: 0.10, green: 0.45, blue: 0.96))
                            bestRow(mode: .lightItUp, icon: "lightbulb.fill", accent: Color(red: 0.62, green: 0.28, blue: 0.92))
                            bestRow(mode: .quizRush, icon: "questionmark.bubble.fill", accent: Color(red: 0.16, green: 0.72, blue: 0.56))
                        }

                        sectionLabel("Score History")
                        chartCard

                        sectionLabel("Recent Games")
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
                colors: [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color(red: 0.62, green: 0.78, blue: 1.0).opacity(0.18), .clear],
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
                Text("PixelPlay Stats")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.12, green: 0.22, blue: 0.43))
                Text("Track performance, recent runs, and leaderboard position.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.34, green: 0.42, blue: 0.56))
            }
            Spacer()
        }
        .padding(.top, 22)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(1.2)
            .foregroundColor(Color(red: 0.36, green: 0.44, blue: 0.58))
            .padding(.horizontal, 4)
    }

    private var leaderboardCard: some View {
        VStack(spacing: 10) {
            if store.leaderboard().isEmpty {
                emptyStateCard(title: "No leaderboard yet", subtitle: "Play a round and your score will appear here.")
            } else {
                VStack(spacing: 10) {
                    ForEach(store.leaderboard(limit: 5)) { session in
                        leaderboardRow(session)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.80, green: 0.88, blue: 0.98), lineWidth: 1)
        )
        .cornerRadius(22)
        .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if store.sessions.isEmpty {
                emptyStateCard(title: "No score history yet", subtitle: "The chart will fill once games are finished.")
            } else {
                Chart(store.recent(20)) { session in
                    BarMark(
                        x: .value("Time", session.timestamp, unit: .minute),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(modeColor(session.mode))
                }
                .frame(height: 180)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.80, green: 0.88, blue: 0.98), lineWidth: 1)
        )
        .cornerRadius(22)
        .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private var recentCard: some View {
        VStack(spacing: 10) {
            if store.sessions.isEmpty {
                emptyStateCard(title: "No games played yet", subtitle: "Finish a round to populate recent history.")
            } else {
                VStack(spacing: 10) {
                    ForEach(store.recent(10)) { session in
                        recentRow(session)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.80, green: 0.88, blue: 0.98), lineWidth: 1)
        )
        .cornerRadius(22)
        .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private func leaderboardRow(_ session: GameSession) -> some View {
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
                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
                Text(session.mode.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.41, green: 0.48, blue: 0.60))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(session.score)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.28))
                Text(session.timestamp, style: .relative)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0.50, green: 0.56, blue: 0.66))
            }
        }
        .padding(14)
        .background(Color(red: 0.98, green: 0.99, blue: 1.0))
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
                .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
            
            Spacer()
            
            Text("\(store.best(for: mode))")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.84, green: 0.90, blue: 0.98), lineWidth: 1)
        )
    }
    
    func recentRow(_ session: GameSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(session.playerName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
                Text(session.mode.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.45, green: 0.52, blue: 0.63))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(session.score) pts")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
                Text(session.timestamp, style: .relative)
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.50, green: 0.56, blue: 0.66))
            }
        }
        .padding(14)
        .background(Color(red: 0.98, green: 0.99, blue: 1.0))
        .cornerRadius(16)
    }

    private func emptyStateCard(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0.45, green: 0.52, blue: 0.63))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(red: 0.98, green: 0.99, blue: 1.0))
        .cornerRadius(16)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let string = String(letters)
        return string.isEmpty ? "P" : string.uppercased()
    }
    
    func modeColor(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return Color(red: 0.10, green: 0.45, blue: 0.96)
        case .lightItUp: return Color(red: 0.62, green: 0.28, blue: 0.92)
        case .quizRush: return Color(red: 0.16, green: 0.72, blue: 0.56)
        }
    }
}
