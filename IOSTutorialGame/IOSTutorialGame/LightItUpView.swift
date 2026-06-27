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
    
    var window: Double {
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
    
    var name: String { "LEVEL \(rawValue)" }
}

struct LightItUpView: View {
    
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 5
    @State private var timeLeft = 60
    @State private var gameActive = false
    @State private var gameOver = false
    @State private var level: Level = .l1
    @State private var showFlash = false
    @State private var litTimer: Timer? = nil
    
    let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if gameOver {
                endScreen
            } else {
                mainView
            }
            
            if showFlash {
                flashOverlay
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
        VStack(spacing: 16) {
            HStack {
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 34, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("SCORE")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .tracking(2)
                }
                
                Spacer()
                
                Text(level.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(level.colour)
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("\(timeLeft)")
                        .font(.system(size: 34, weight: .bold, design: .monospaced))
                        .foregroundColor(timeLeft <= 10 ? .red : .white)
                    Text("TIME")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .tracking(2)
                }
            }
            .padding(.horizontal)
            
            // lives
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .foregroundColor(i < lives ? .red : Color(white: 0.3))
                        .font(.system(size: 18))
                }
            }
            
            Spacer()
            
            if !gameActive {
                Button("START") { beginGame() }
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.black)
                    .frame(width: 150, height: 56)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                cardGrid
            }
            
            Spacer()
            
            Text("best: \(highScore)")
                .font(.footnote)
                .foregroundColor(Color(white: 0.35))
        }
        .padding(.top, 8)
    }
    
    var cardGrid: some View {
        let gridCols = Array(repeating: GridItem(.flexible(), spacing: 10), count: level.cols)
        return LazyVGrid(columns: gridCols, spacing: 10) {
            ForEach(cards) { card in
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.isLit ? level.colour : Color(white: 0.13))
                    .frame(height: 88)
                    .scaleEffect(card.isLit ? 1.04 : 1.0)
                    .shadow(color: card.isLit ? level.colour.opacity(0.6) : .clear, radius: 10)
                    .animation(.easeOut(duration: 0.15), value: card.isLit)
                    .onTapGesture { tapped(card) }
            }
        }
        .padding(.horizontal)
    }
    
    var endScreen: some View {
        VStack(spacing: 20) {
            Text("GAME OVER")
                .font(.system(size: 30, weight: .black))
                .foregroundColor(.white)
            
            if score > 0 && score >= highScore {
                Text("🏆 new high score!")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.yellow)
            }
            
            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 80, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                Text("points")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("best: \(highScore)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button("play again") { restartGame() }
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 150, height: 48)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.top, 8)
        }
        .padding()
    }
    
    var flashOverlay: some View {
        Text(level.name)
            .font(.system(size: 38, weight: .black))
            .foregroundColor(level.colour)
            .padding(28)
            .background(Color.black.opacity(0.88))
            .cornerRadius(18)
            .transition(.opacity)
    }
    
    func tapped(_ card: Card) {
        guard gameActive,
              let i = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        if cards[i].isLit {
            score += 1
            withAnimation { cards[i].isLit = false }
        } else {
            lives -= 1
            if lives <= 0 { finish() }
        }
    }
    
    func beginGame() {
        score = 0
        lives = 5
        timeLeft = 60
        level = .l1
        gameOver = false
        gameActive = true
        rebuildCards()
        scheduleLitTimer()
    }
    
    func finish() {
        gameActive = false
        gameOver = true
        litTimer?.invalidate()
        if score > highScore { highScore = score }
    }
    
    func restartGame() {
        score = 0
        lives = 5
        timeLeft = 60
        level = .l1
        gameOver = false
        gameActive = false
        cards = []
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
        litTimer = Timer.scheduledTimer(withTimeInterval: level.window, repeats: true) { _ in
            withAnimation {
                for i in cards.indices { cards[i].isLit = false }
                var pool = Array(0..<cards.count).shuffled()
                for _ in 0..<level.litCount {
                    if !pool.isEmpty { cards[pool.removeFirst()].isLit = true }
                }
            }
        }
    }
}
