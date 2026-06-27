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
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
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
    
    @AppStorage("lightItUpHighScore") private var highScore = 0
    @AppStorage("lightItUpHighStreak") private var highStreak = 0
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 5
    @State private var timeLeft = 60
    @State private var gameActive = false
    @State private var gameOver = false
    @State private var level: Level = .l1
    @State private var showFlash = false
    @State private var litTimer: Timer? = nil
    @State private var streak = 0
    @State private var bestStreakThisRound = 0
    @State private var streakFeedback = ""
    @State private var showStreakFeedback = false
    
    // window shrinks as streak grows
    var currentWindow: Double {
        let reduction = min(Double(streak) * 0.05, 0.4)
        return max(level.baseWindow - reduction, 0.4)
    }
    
    let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            
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
    }
    
    var mainView: some View {
        VStack(spacing: 0) {
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Text("score")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.4))
                }
                
                Spacer()
                
                VStack(spacing: 6) {
                    Text(level.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(level.colour)
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: i < lives ? "heart.fill" : "heart")
                                .foregroundColor(i < lives ? .red : Color(white: 0.25))
                                .font(.system(size: 13))
                        }
                    }
                    if streak > 2 {
                        Text("🔥 \(streak) streak")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(timeLeft)")
                        .font(.system(size: 48, weight: .black, design: .monospaced))
                        .foregroundColor(timeLeft <= 10 ? .red : Color(white: 0.85))
                    Text("secs left")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.4))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
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
            
            Text("best  \(highScore)")
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.3))
                .padding(.bottom, 30)
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
                            if card.isLit && card.type == .bonus {
                                Text("+3")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.black)
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
        return card.type == .bonus ? .yellow : level.colour
    }
    
    func cardGlow(_ card: Card) -> Color {
        card.type == .bonus ? Color.yellow.opacity(0.6) : level.colour.opacity(0.55)
    }
    
    var endScreen: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("game over")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(white: 0.5))
            
            Text("\(score)")
                .font(.system(size: 96, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .padding(.top, 4)
            
            Text("points")
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.4))
            
            if score > 0 && score >= highScore {
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
                        .foregroundColor(Color(white: 0.4))
                }
                VStack(spacing: 3) {
                    Text("\(highStreak)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(Color(white: 0.6))
                    Text("all-time streak")
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.4))
                }
            }
            .padding(.top, 16)
            
            Text("best score  \(highScore)")
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.35))
                .padding(.top, 8)
            
            Spacer()
            
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
            let pts = cards[i].type == .bonus ? 3 : 1
            score += pts
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
        score = 0; lives = 5; timeLeft = 60
        streak = 0; bestStreakThisRound = 0
        level = .l1; gameOver = false; gameActive = true
        rebuildCards()
        scheduleLitTimer()
    }
    
    func finish() {
        gameActive = false; gameOver = true
        litTimer?.invalidate()
        if score > highScore { highScore = score }
    }
    
    func restartGame() {
        score = 0; lives = 5; timeLeft = 60
        streak = 0; bestStreakThisRound = 0
        level = .l1; gameOver = false; gameActive = false; cards = []
    }
    
    func rebuildCards() {
        cards = (0..<level.cardCount).map { Card(id: $0) }
    }
    
    func checkLevelUp() {
        let elapsed = 60 - timeLeft
        let next: Level
        if elapsed < 15 { next = .l1 }
        else if elapsed < 30 { next = .l2 }
        else if elapsed < 45 { next = .l3 }
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
                        // 20% chance first card is bonus, never second
                        self.cards[idx].type = (j == 0 && Int.random(in: 0..<5) == 0) ? .bonus : .normal
                    }
                }
            }
        }
    }
}
