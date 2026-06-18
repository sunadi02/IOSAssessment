import SwiftUI
import Combine

enum Level: Int, CaseIterable {
    case l1 = 1, l2, l3, l4
    
    var cardCount: Int {
        switch self { case .l1: return 3; case .l2: return 4; case .l3: return 6; case .l4: return 9 }
    }
    var columns: Int {
        switch self { case .l1: return 3; case .l2: return 2; case .l3: return 3; case .l4: return 3 }
    }
    var litWindow: Double {
        switch self { case .l1: return 1.5; case .l2: return 1.2; case .l3: return 1.0; case .l4: return 0.8 }
    }
    var litCount: Int { self == .l4 ? 2 : 1 }
    var glowColor: Color {
        switch self { case .l1: return .blue; case .l2: return .green; case .l3: return .orange; case .l4: return .red }
    }
    var label: String { "LEVEL \(rawValue)" }
}

struct LightItUpView: View {
    
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60
    @State private var gameActive = false
    @State private var gameOver = false
    @State private var currentLevel: Level = .l1
    @State private var showLevelFlash = false
    @State private var litTimer: Timer? = nil
    
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if gameOver {
                gameOverView
            } else {
                gameView
            }
            
            if showLevelFlash {
                levelFlashOverlay
            }
        }
        .onReceive(countdownTimer) { _ in
            guard gameActive else { return }
            if timeLeft > 0 {
                timeLeft -= 1
                updateLevel()
            } else {
                endGame()
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var gameView: some View {
        VStack(spacing: 20) {
            
            HStack {
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("SCORE").font(.caption).foregroundColor(.gray).tracking(2)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(currentLevel.label)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(currentLevel.glowColor)
                    Text("").font(.caption).foregroundColor(.clear)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("\(timeLeft)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(timeLeft <= 10 ? .red : .white)
                    Text("TIME").font(.caption).foregroundColor(.gray).tracking(2)
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .foregroundColor(i < lives ? .red : .gray)
                        .font(.system(size: 20))
                }
            }
            
            Spacer()
            
            if !gameActive && !gameOver {
                Button("START") { startGame() }
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.black)
                    .frame(width: 160, height: 60)
                    .background(Color.white)
                    .cornerRadius(14)
            } else {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: currentLevel.columns)
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(cards) { card in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(card.isLit ? currentLevel.glowColor : Color(white: 0.15))
                            .frame(height: 90)
                            .scaleEffect(card.isLit ? 1.05 : 1.0)
                            .shadow(color: card.isLit ? currentLevel.glowColor.opacity(0.7) : .clear, radius: 12)
                            .animation(.easeInOut(duration: 0.2), value: card.isLit)
                            .onTapGesture { handleCardTap(card) }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Text("Best: \(highScore)")
                .font(.footnote).foregroundColor(.gray)
        }
        .padding(.top)
    }
    
    var gameOverView: some View {
        VStack(spacing: 24) {
            Text("GAME OVER")
                .font(.system(size: 32, weight: .black)).foregroundColor(.white)
            
            if score >= highScore && score > 0 {
                Text("🏆 NEW HIGH SCORE!")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.yellow)
            }
            
            VStack(spacing: 8) {
                Text("\(score)")
                    .font(.system(size: 72, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                Text("POINTS")
                    .font(.caption).foregroundColor(.gray).tracking(4)
            }
            
            Text("Best: \(highScore)")
                .font(.subheadline).foregroundColor(.gray)
            
            Button("PLAY AGAIN") { resetGame() }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 160, height: 50)
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding()
    }
    
    var levelFlashOverlay: some View {
        Text(currentLevel.label)
            .font(.system(size: 40, weight: .black))
            .foregroundColor(currentLevel.glowColor)
            .padding(30)
            .background(Color.black.opacity(0.85))
            .cornerRadius(20)
            .transition(.opacity)
    }
    
    func handleCardTap(_ card: Card) {
        guard gameActive, let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        if cards[index].isLit {
            score += 1
            withAnimation { cards[index].isLit = false }
        } else {
            lives -= 1
            if lives <= 0 { endGame() }
        }
    }
    
    func startGame() {
        score = 0; lives = 3; timeLeft = 60
        currentLevel = .l1; gameOver = false; gameActive = true
        buildCards()
        startLitTimer()
    }
    
    func endGame() {
        gameActive = false; gameOver = true
        litTimer?.invalidate()
        if score > highScore { highScore = score }
    }
    
    func resetGame() {
        score = 0; lives = 3; timeLeft = 60
        currentLevel = .l1; gameOver = false; gameActive = false
        cards = []
    }
    
    func buildCards() {
        cards = (0..<currentLevel.cardCount).map { Card(id: $0) }
    }
    
    func updateLevel() {
        let elapsed = 60 - timeLeft
        let newLevel: Level
        if elapsed < 15 { newLevel = .l1 }
        else if elapsed < 30 { newLevel = .l2 }
        else if elapsed < 45 { newLevel = .l3 }
        else { newLevel = .l4 }
        
        if newLevel != currentLevel {
            currentLevel = newLevel
            buildCards()
            startLitTimer()
            flashLevel()
        }
    }
    
    func flashLevel() {
        withAnimation { showLevelFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showLevelFlash = false }
        }
    }
    
    func startLitTimer() {
        litTimer?.invalidate()
        litTimer = Timer.scheduledTimer(withTimeInterval: currentLevel.litWindow, repeats: true) { _ in
            withAnimation {
                for i in cards.indices { cards[i].isLit = false }
                var indices = Array(0..<cards.count).shuffled()
                for _ in 0..<currentLevel.litCount {
                    if !indices.isEmpty { cards[indices.removeFirst()].isLit = true }
                }
            }
        }
    }
}
