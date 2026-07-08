import SwiftUI

struct HomeTab: View {
    @ObservedObject private var store = SessionStore.shared
    @ObservedObject private var location = LocationService.shared
    @AppStorage("playerName") private var playerName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        profileCard

                        GameCardLink(
                            title: "Tap Frenzy",
                            subtitle: "Rapid Tap Challenge",
                            icon: "hand.tap.fill",
                            iconColors: [Color(red: 0.15, green: 0.39, blue: 0.93), Color(red: 0.30, green: 0.77, blue: 1.0)],
                            cardColors: [Color(red: 0.10, green: 0.45, blue: 0.96), Color(red: 0.18, green: 0.74, blue: 0.99)]
                        ) {
                            statsRow(leftLabel: "High Score", leftValue: "\(store.best(for: .tapFrenzy))", rightLabel: "Plays", rightValue: "\(playCount(for: .tapFrenzy))")
                        } destination: {
                            TapFrenzyView()
                        }

                        GameCardLink(
                            title: "Light It Up",
                            subtitle: "Connect the Circuit",
                            icon: "lightbulb.fill",
                            iconColors: [Color(red: 0.44, green: 0.20, blue: 0.70), Color(red: 0.99, green: 0.58, blue: 0.25)],
                            cardColors: [Color(red: 0.51, green: 0.20, blue: 0.76), Color(red: 0.94, green: 0.55, blue: 0.26)]
                        ) {
                            statsRow(leftLabel: "High Score", leftValue: "\(store.best(for: .lightItUp))", rightLabel: "Games", rightValue: "\(playCount(for: .lightItUp))")
                        } destination: {
                            LightItUpView()
                        }

                        GameCardLink(
                            title: "Quiz Rush",
                            subtitle: "Fast General Knowledge",
                            icon: "brain.head.profile",
                            iconColors: [Color(red: 0.08, green: 0.60, blue: 0.58), Color(red: 0.92, green: 0.89, blue: 0.20)],
                            cardColors: [Color(red: 0.15, green: 0.72, blue: 0.61), Color(red: 0.82, green: 0.90, blue: 0.16)]
                        ) {
                            statsRow(leftLabel: "Top Score", leftValue: "\(store.best(for: .quizRush))", rightLabel: "Answers", rightValue: "\(estimatedCorrectAnswers)")
                        } destination: {
                            QuizRushView()
                        }

                        NavigationLink(destination: StatsTab()) {
                            leaderboardCard
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 18)
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
                colors: [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.94, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.blue.opacity(0.12), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 340
            )
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("PixelPlay")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.12, green: 0.22, blue: 0.43))

            Spacer()

            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.12, green: 0.22, blue: 0.43))
                        .frame(width: 34, height: 34)
                    Image(systemName: "person.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                Text(displayName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.26))
            }
        }
        .padding(.top, 24)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your name")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.30, green: 0.38, blue: 0.52))
                    TextField("Enter your name", text: $playerName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.28))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current location")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.30, green: 0.38, blue: 0.52))
                    Text(location.locationDescription)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.16, green: 0.22, blue: 0.34))
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.78, green: 0.87, blue: 0.98), lineWidth: 1)
        )
        .cornerRadius(22)
        .shadow(color: Color.blue.opacity(0.10), radius: 14, x: 0, y: 8)
    }

    private var leaderboardCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text("VIEW LEADERBOARDS")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Compare your scores with players worldwide!")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.82))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.12, blue: 0.32), Color(red: 0.08, green: 0.18, blue: 0.46)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.cyan.opacity(0.7), lineWidth: 1.8)
                .shadow(color: Color.cyan.opacity(0.5), radius: 14)
        )
        .cornerRadius(22)
        .shadow(color: Color.blue.opacity(0.25), radius: 14, x: 0, y: 8)
    }

    private func statsRow(leftLabel: String, leftValue: String, rightLabel: String, rightValue: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(leftLabel): \(leftValue)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
                Text("\(rightLabel): \(rightValue)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
            }
            Spacer()
            Text("PLAY NOW")
                .font(.system(size: 15, weight: .black))
                .foregroundColor(Color(red: 0.15, green: 0.44, blue: 0.78))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(18)
        }
    }

    private func playCount(for mode: GameMode) -> Int {
        store.recent(200).filter { $0.mode == mode }.count
    }

    private var estimatedCorrectAnswers: Int {
        max(store.best(for: .quizRush), store.recent(200).filter { $0.mode == .quizRush }.map { $0.score }.reduce(0, +) / 10)
    }

    private var displayName: String {
        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Player" : trimmed
    }
}

private struct GameCardLink<Destination: View, Detail: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColors: [Color]
    let cardColors: [Color]
    let detail: Detail
    let destination: Destination

    @State private var hovering = false

    init(
        title: String,
        subtitle: String,
        icon: String,
        iconColors: [Color],
        cardColors: [Color],
        @ViewBuilder detail: () -> Detail,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColors = iconColors
        self.cardColors = cardColors
        self.detail = detail()
        self.destination = destination()
    }

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: iconColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 96, height: 96)
                            .shadow(color: iconColors.last?.opacity(0.35) ?? .clear, radius: 10, x: 0, y: 8)

                        Image(systemName: icon)
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.8)
                        Text(subtitle)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)
                }

                detail
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: cardColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
                    .mask(RoundedRectangle(cornerRadius: 24))
            )
            .cornerRadius(24)
            .shadow(color: cardColors.last?.opacity(0.22) ?? .black.opacity(0.15), radius: 18, x: 0, y: 10)
            .scaleEffect(hovering ? 1.02 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.82), value: hovering)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 24))
        .onHover { hovering = $0 }
    }
}
