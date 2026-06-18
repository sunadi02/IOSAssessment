import SwiftUI
import Combine

struct TapFrenzyView: View {
    
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var gameActive = false
    @State private var gameOver = false
    @State private var isPressed = false
    @State private var comboMultiplier = 1
    @State private var lastTapTime: Date? = nil
    @State private var isGreenMode = false
    @State private var trapTimer: Timer? = nil
    
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if gameOver {
                gameOverView
            } else {
                gameView
            }
        }
        .onReceive(countdownTimer) { _ in
            guard gameActive else { return }
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                endGame()
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var gameView: some View {
        VStack(spacing: 30) {
            HStack(spacing: 60) {
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 52, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("SCORE")
                        .font(.caption).foregroundColor(.gray).tracking(2)
                }
                VStack(spacing: 4) {
                    Text("\(timeLeft)")
                        .font(.system(size: 52, weight: .bold, design: .monospaced))
                        .foregroundColor(timeLeft <= 3 ? .red : .white)
                    Text("TIME")
                        .font(.caption).foregroundColor(.gray).tracking(2)
                }
            }
            
            if comboMultiplier > 1 {
                Text("COMBO x\(comboMultiplier)!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
            
            Button(action: handleTap) {
                Circle()
                    .fill(isGreenMode ? Color.green : Color.white)
                    .frame(width: 200, height: 200)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.15, dampingFraction: 0.5), value: isPressed)
                    .overlay(
                        Text(gameActive ? "TAP!" : "START")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(.black)
                    )
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("Best: \(highScore)")
                .font(.footnote).foregroundColor(.gray)
        }
        .padding()
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
                Text("TAPS")
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
    
    func handleTap() {
        if !gameActive { startGame(); return }
        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) < 0.5 {
            comboMultiplier = min(comboMultiplier + 1, 5)
        } else {
            comboMultiplier = 1
        }
        lastTapTime = now
        let points = isGreenMode ? 2 : 1
        score += points * comboMultiplier
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isPressed = false }
    }
    
    func startGame() {
        score = 0; timeLeft = 10; gameOver = false; gameActive = true
        comboMultiplier = 1; lastTapTime = nil
        startTrapTimer()
    }
    
    func endGame() {
        gameActive = false; gameOver = true
        if score > highScore { highScore = score }
        trapTimer?.invalidate()
    }
    
    func resetGame() {
        score = 0; timeLeft = 10; gameOver = false; gameActive = false; isGreenMode = false
    }
    
    func startTrapTimer() {
        trapTimer?.invalidate()
        trapTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) { self.isGreenMode = Bool.random() }
        }
    }
}
