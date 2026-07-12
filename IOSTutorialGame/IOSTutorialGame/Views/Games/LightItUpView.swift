import SwiftUI
import Combine

enum Level: Int, CaseIterable {
    case l1 = 1, l2, l3, l4
    
    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }
    
    var cols: Int {
        switch self {
        case .l1: return 3
        case .l2: return 2
        case .l3: return 3
        case .l4: return 3
        }
    }
    
    var baseWindow: Double {
        switch self {
        case .l1: return 1.3
        case .l2: return 1.1
        case .l3: return 0.9
        case .l4: return 0.75
        }
    }
    
    var litCount: Int { self == .l4 ? 2 : 1 }
    
    var colour: Color {
        switch self {
        case .l1: return .blue
        case .l2: return .green
        case .l3: return .orange
        case .l4: return .red
        }
    }
    
    var name: String { "Level \(rawValue)" }
}

struct LightItUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let isChallengeMode: Bool
    
    @AppStorage("lightItUpHighScore") private var highScore = 0
    @AppStorage("lightItUpHighStreak") private var highStreak = 0
    @AppStorage("playerName") private var playerName = "Player"
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 5
    @State private var timeLeft = 150
    @State private var gameActive = false
    @State private var gameOver = false
    @State private var level: Level = .l1
    @State private var showFlash = false
    @State private var litTimer: Timer? = nil
    @State private var streak = 0
    @State private var bestStreakThisRound = 0
    @State private var streakFeedback = ""
    @State private var showStreakFeedback = false

    private let roundDuration = 150

    init(isChallengeMode: Bool = false) {
        self.isChallengeMode = isChallengeMode
    }
    
    // window shrinks as streak grows
    var currentWindow: Double {
        let streakReduction = min(Double(streak) * 0.05, 0.35)
        return max(level.baseWindow - streakReduction, 0.55)
    }

    private var isDarkMode: Bool {
        colorScheme == .dark
    }

    private var shellBackground: Color {
        isDarkMode ? Color(red: 0.06, green: 0.07, blue: 0.11) : Color(red: 0.08, green: 0.10, blue: 0.16)
    }

    private var shellBorder: Color {
        isDarkMode ? Color.white.opacity(0.12) : Color.white.opacity(0.08)
    }

    private var heroPrimary: Color {
        isDarkMode ? .white : Color(red: 0.12, green: 0.22, blue: 0.43)
    }

    private var heroSecondary: Color {
        isDarkMode ? Color.white.opacity(0.68) : Color(red: 0.40, green: 0.48, blue: 0.60)
    }

    private var mutedText: Color {
        isDarkMode ? Color.white.opacity(0.58) : Color(white: 0.4)
    }

    private var panelText: Color {
        .white
    }

    private var timeDisplay: String {
        String(format: "%d:%02d", timeLeft / 60, timeLeft % 60)
    }
    
    let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            background

            VStack(spacing: 16) {
                topBar

                ZStack {
                    if gameOver {
                        endScreen
                    } else {
                        mainView
                    }

                    if showFlash {
                        flashOverlay
                    }

                    if showStreakFeedback {
                        VStack {
                            Spacer()
                            Text(streakFeedback)
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(.yellow)
                                .padding(.bottom, 120)
                                .transition(.opacity)
                        }
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(shellBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                    .stroke(shellBorder, lineWidth: 1)
                )
                .cornerRadius(28)
            }
        }
        .onReceive(ticker) { _ in
            guard gameActive else { return }
            if timeLeft > 0 {
                timeLeft -= 1
                checkLevelUp()
            } else {
                finish()
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    var background: some View {
        LinearGradient(
            colors: isDarkMode ? [Color(red: 0.03, green: 0.04, blue: 0.07), Color(red: 0.08, green: 0.09, blue: 0.14), Color(red: 0.05, green: 0.06, blue: 0.10)] : [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(heroPrimary)
                    .frame(width: 38, height: 38)
                    .background(isDarkMode ? Color(red: 0.14, green: 0.17, blue: 0.25) : Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(isDarkMode ? 0.20 : 0.10), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Playzo")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(heroPrimary)
                Text("Light It Up")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(heroSecondary)
            }

            if isChallengeMode {
                Spacer()

                Text("DAILY CHALLENGE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(Color(red: 0.12, green: 0.48, blue: 0.88))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white)
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 0.80, green: 0.88, blue: 0.98), lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }

            Spacer()
        }
    }
    
    var mainView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .black, design: .monospaced))
                        .foregroundColor(panelText)
                    Text("score")
                        .font(.system(size: 12))
                        .foregroundColor(mutedText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(timeDisplay)
                        .font(.system(size: 42, weight: .black, design: .monospaced))
                        .foregroundColor(timeLeft <= 10 ? .red : (isDarkMode ? .white : Color(white: 0.85)))
                    Text("time left")
                        .font(.system(size: 12))
                        .foregroundColor(mutedText)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            VStack(alignment: .center, spacing: 6) {
                Text(level.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(level.colour)
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: i < lives ? "heart.fill" : "heart")
                            .foregroundColor(i < lives ? .red : mutedText)
                            .font(.system(size: 13))
                    }
                }
                if streak > 2 {
                    Text("🔥 \(streak) streak")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
            Spacer()
            
            if !gameActive {
                Button("START") { beginGame() }
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.black)
                    .frame(width: 140, height: 52)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                cardGrid
            }
            
            Spacer()
            
            if !isChallengeMode {
                Text("best  \(highScore)")
                    .font(.system(size: 13))
                    .foregroundColor(mutedText)
                    .padding(.bottom, 30)
            } else {
                Spacer(minLength: 30)
            }
        }
    }
    
    var cardGrid: some View {
        let gridCols = Array(
            repeating: GridItem(.flexible(), spacing: 10),
            count: level.cols
        )
        return LazyVGrid(columns: gridCols, spacing: 10) {
            ForEach(cards) { card in
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColour(card))
                    .frame(height: 85)
                    .scaleEffect(card.isLit ? 1.03 : 1.0)
                    .shadow(
                        color: card.isLit ? cardGlow(card) : .clear,
                        radius: 10
                    )
                    .overlay(
                        Group {
                            if card.isLit {
                                switch card.type {
                                case .bonus:
                                    Text("+3")
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundColor(.black)
                                case .heart:
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(.white)
                                case .normal:
                                    EmptyView()
                                }
                            }
                        }
                    )
                    .animation(.easeOut(duration: 0.15), value: card.isLit)
                    .onTapGesture { tapped(card) }
            }
        }
        .padding(.horizontal, 20)
    }
    
    func cardColour(_ card: Card) -> Color {
        if !card.isLit { return Color(white: 0.13) }
        switch card.type {
        case .bonus: return .yellow
        case .heart: return .pink
        case .normal: return level.colour
        }
    }
    
    func cardGlow(_ card: Card) -> Color {
        switch card.type {
        case .bonus: return Color.yellow.opacity(0.6)
        case .heart: return Color.pink.opacity(0.6)
        case .normal: return level.colour.opacity(0.55)
        }
    }
    
    var endScreen: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("game over")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(mutedText)
            
            Text("\(score)")
                .font(.system(size: 96, weight: .black, design: .monospaced))
                .foregroundColor(panelText)
                .padding(.top, 4)
            
            Text("points")
                .font(.system(size: 14))
                .foregroundColor(mutedText)
            
            if !isChallengeMode, score > 0 && score >= highScore {
                Text("🏆 new best!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.yellow)
                    .padding(.top, 10)
            }
            
            HStack(spacing: 30) {
                VStack(spacing: 3) {
                    Text("\(bestStreakThisRound)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.orange)
                    Text("best streak")
                        .font(.system(size: 11))
                        .foregroundColor(mutedText)
                }
                VStack(spacing: 3) {
                    Text("\(highStreak)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(isDarkMode ? Color(white: 0.78) : Color(white: 0.6))
                    Text("all-time streak")
                        .font(.system(size: 11))
                        .foregroundColor(mutedText)
                }
            }
            .padding(.top, 16)
            
            if !isChallengeMode {
                Text("best score  \(highScore)")
                    .font(.system(size: 13))
                    .foregroundColor(mutedText)
                    .padding(.top, 8)
            }
            
            Spacer()
            if !isChallengeMode {
                ShareLink(item: "I just scored \(score) on Quiz Rush 🎮 — beat that!") {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("share score")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 180, height: 44)
                    .background(Color(white: 0.18))
                    .cornerRadius(10)
                }
                .padding(.bottom, 12)
            }
            Button("play again") { restartGame() }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 140, height: 46)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.bottom, 50)
        }
    }
    
    var flashOverlay: some View {
        Text(level.name)
            .font(.system(size: 36, weight: .black))
            .foregroundColor(level.colour)
            .padding(26)
            .background(Color.black.opacity(0.9))
            .cornerRadius(16)
            .transition(.opacity)
    }
    
    func tapped(_ card: Card) {
        guard gameActive,
              let i = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        if cards[i].isLit {
            switch cards[i].type {
            case .bonus:
                score += 3
            case .heart:
                lives = min(5, lives + 1)
            case .normal:
                score += 1
            }
            streak += 1
            bestStreakThisRound = max(bestStreakThisRound, streak)
            
            if streak > highStreak { highStreak = streak }
            
            withAnimation { cards[i].isLit = false }
            
            // reschedule timer with new (faster) window when streak changes
            scheduleLitTimer()
            showStreakMessage()
        } else {
            streak = 0
            lives -= 1
            if lives <= 0 { finish() }
        }
    }
    
    func showStreakMessage() {
        if streak == 5 { streakFeedback = "🔥 on fire!" }
        else if streak == 10 { streakFeedback = "💥 unstoppable!" }
        else if streak == 20 { streakFeedback = "🚀 insane!" }
        else { return }
        
        withAnimation { showStreakFeedback = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showStreakFeedback = false }
        }
    }
    
    func beginGame() {
        score = 0; lives = 5; timeLeft = roundDuration
        streak = 0; bestStreakThisRound = 0
        level = .l1; gameOver = false; gameActive = true
        rebuildCards()
        scheduleLitTimer()
    }
    
    func finish() {
        gameActive = false; gameOver = true
        litTimer?.invalidate()
        if !isChallengeMode {
            if score > highScore { highScore = score }
            if bestStreakThisRound > highStreak { highStreak = bestStreakThisRound }
            let loc = LocationService.shared.coordinate
            SessionStore.shared.save(GameSession(mode: .lightItUp, score: score, playerName: playerName, latitude: loc.lat, longitude: loc.lon))
        }
    }
    
    func restartGame() {
        score = 0; lives = 5; timeLeft = roundDuration
        streak = 0; bestStreakThisRound = 0
        level = .l1; gameOver = false; gameActive = false; cards = []
    }
    
    func rebuildCards() {
        cards = (0..<level.cardCount).map { Card(id: $0) }
    }
    
    func checkLevelUp() {
        let elapsed = roundDuration - timeLeft
        let next: Level
        if elapsed < 37 { next = .l1 }
        else if elapsed < 75 { next = .l2 }
        else if elapsed < 112 { next = .l3 }
        else { next = .l4 }
        guard next != level else { return }
        level = next
        rebuildCards()
        scheduleLitTimer()
        showLevelFlash()
    }
    
    func showLevelFlash() {
        withAnimation { showFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showFlash = false }
        }
    }
    
    func scheduleLitTimer() {
        litTimer?.invalidate()
        litTimer = Timer.scheduledTimer(withTimeInterval: currentWindow, repeats: true) { _ in
            withAnimation {
                for i in self.cards.indices { self.cards[i].isLit = false }
                var pool = Array(0..<self.cards.count).shuffled()
                
                for j in 0..<self.level.litCount {
                    if !pool.isEmpty {
                        let idx = pool.removeFirst()
                        self.cards[idx].isLit = true
                        if j == 0 && Int.random(in: 0..<14) == 0 {
                            self.cards[idx].type = .heart
                        } else if j == 0 && Int.random(in: 0..<5) == 0 {
                            self.cards[idx].type = .bonus
                        } else {
                            self.cards[idx].type = .normal
                        }
                    }
                }
            }
        }
    }
}
