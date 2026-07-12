
import SwiftUI

struct InfiniteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("infiniteHighScore") private var highScore = 0
    @AppStorage("infiniteHighStreak") private var highStreak = 0
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var gameActive = false
    @State private var gameOver = false
    @State private var streak = 0
    @State private var bestStreakThisRound = 0
    @State private var litTimer: Timer? = nil
    @State private var showFeedback = false
    @State private var feedbackText = ""
    
    // speed increases every 10 points
    var currentWindow: Double {
        let speedUps = score / 10
        return max(1.4 - Double(speedUps) * 0.08, 0.35)
    }
    
    var gridSize: Int {
        if score < 10 { return 4 }
        if score < 25 { return 6 }
        return 9
    }
    
    var cols: Int { gridSize == 4 ? 2 : 3 }
    
    var cardColourForScore: Color {
        if score < 10 { return .blue }
        if score < 25 { return .green }
        if score < 40 { return .orange }
        return .red
    }

    private var shellBackground: Color { Color(uiColor: .secondarySystemBackground) }
    private var shellBorder: Color { Color(uiColor: .tertiarySystemFill) }
    private var heroPrimary: Color { Color(uiColor: .label) }
    private var heroSecondary: Color { Color(uiColor: .secondaryLabel) }
    
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

                    if showFeedback {
                        VStack {
                            Spacer()
                            Text(feedbackText)
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
        .navigationTitle("Infinite")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    var background: some View {
        LinearGradient(
            colors: colorScheme == .dark ? [Color(red: 0.04, green: 0.05, blue: 0.08), Color(red: 0.08, green: 0.09, blue: 0.14), Color(red: 0.06, green: 0.07, blue: 0.10)] : [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
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
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.10), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Playzo")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(heroPrimary)
                Text("Infinite")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(heroSecondary)
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
                        .foregroundColor(.white)
                    Text("score")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.4))
                }
                
                Spacer()
                
                VStack(spacing: 5) {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < lives ? "heart.fill" : "heart")
                                .foregroundColor(i < lives ? .red : Color(white: 0.25))
                                .font(.system(size: 16))
                        }
                    }
                    if streak > 2 {
                        Text("🔥 \(streak)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("∞")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(cardColourForScore)
                    Text("no timer")
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
        let gridCols = Array(repeating: GridItem(.flexible(), spacing: 10), count: cols)
        return LazyVGrid(columns: gridCols, spacing: 10) {
            ForEach(cards) { card in
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.isLit ? (card.type == .bonus ? Color.yellow : cardColourForScore) : Color(white: 0.13))
                    .frame(height: 85)
                    .scaleEffect(card.isLit ? 1.03 : 1.0)
                    .shadow(color: card.isLit ? cardColourForScore.opacity(0.5) : .clear, radius: 10)
                    .overlay(
                        Group {
                            if card.isLit && card.type == .bonus {
                                Text("+3")
                                    .font(.system(size: 18, weight: .black))
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
    
    var endScreen: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("game over")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(uiColor: .secondaryLabel))
            
            Text("\(score)")
                .font(.system(size: 96, weight: .black, design: .monospaced))
                    .foregroundColor(Color(uiColor: .label))
                .padding(.top, 4)
            
            Text("points")
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: .secondaryLabel))
            
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
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }
                VStack(spacing: 3) {
                    Text("\(highStreak)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    Text("all-time streak")
                        .font(.system(size: 11))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                }
            }
            .padding(.top, 16)
            
            Text("best score  \(highScore)")
                .font(.system(size: 13))
                .foregroundColor(Color(uiColor: .secondaryLabel))
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
            scheduleLitTimer()
            showStreakMessage()
        } else {
            streak = 0
            lives -= 1
            if lives <= 0 { finish() }
        }
    }
    
    func showStreakMessage() {
        if streak == 5 { feedbackText = "🔥 on fire!" }
        else if streak == 10 { feedbackText = "💥 unstoppable!" }
        else if streak == 20 { feedbackText = "🚀 insane!" }
        else { return }
        withAnimation { showFeedback = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showFeedback = false }
        }
    }
    
    func beginGame() {
        score = 0; lives = 3; streak = 0; bestStreakThisRound = 0
        gameOver = false; gameActive = true
        rebuildCards()
        scheduleLitTimer()
    }
    
    func finish() {
        gameActive = false; gameOver = true
        litTimer?.invalidate()
        if score > highScore { highScore = score }
    }
    
    func restartGame() {
        score = 0; lives = 3; streak = 0; bestStreakThisRound = 0
        gameOver = false; gameActive = false; cards = []
    }
    
    func rebuildCards() {
        cards = (0..<gridSize).map { Card(id: $0) }
    }
    
    func scheduleLitTimer() {
        litTimer?.invalidate()
        litTimer = Timer.scheduledTimer(withTimeInterval: currentWindow, repeats: true) { _ in
            withAnimation {
                for i in self.cards.indices { self.cards[i].isLit = false }
                // rebuild cards if grid size changed
                if self.cards.count != self.gridSize { self.rebuildCards() }
                var pool = Array(0..<self.cards.count).shuffled()
                if !pool.isEmpty {
                    let idx = pool.removeFirst()
                    self.cards[idx].isLit = true
                    self.cards[idx].type = Int.random(in: 0..<5) == 0 ? .bonus : .normal
                }
            }
        }
    }
}
