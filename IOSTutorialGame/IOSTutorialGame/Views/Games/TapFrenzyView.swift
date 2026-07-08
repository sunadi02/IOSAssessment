import SwiftUI
import Combine

struct TapFrenzyView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    @AppStorage("playerName") private var playerName = "Player"
    
    @State private var score = 0
    @State private var timeLeft = 10
    @State private var gameActive = false
    @State private var gameOver = false
    @State private var btnPressed = false
    @State private var combo = 1
    @State private var lastTap: Date? = nil
    @State private var greenMode = false
    @State private var colourTimer: Timer? = nil
    
    let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            background

            VStack(spacing: 16) {
                topBar

                Group {
                    if gameOver {
                        endScreen
                    } else {
                        mainView
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.08, green: 0.10, blue: 0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .cornerRadius(28)
            }
        }
        .onReceive(ticker) { _ in
            guard gameActive else { return }
            timeLeft -= 1
            if timeLeft <= 0 { finish() }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    var background: some View {
        LinearGradient(
            colors: [Color(red: 0.98, green: 0.99, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
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
                    .foregroundColor(Color(red: 0.12, green: 0.22, blue: 0.43))
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.10), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Arcade Atlas")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.12, green: 0.22, blue: 0.43))
                Text("Tap Frenzy")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.40, green: 0.48, blue: 0.60))
            }

            Spacer()
        }
    }
    
    var mainView: some View {
        VStack(spacing: 28) {
            HStack(spacing: 52) {
                statBlock(value: "\(score)", label: "SCORE")
                statBlock(value: "\(timeLeft)", label: "TIME", highlight: timeLeft <= 3)
            }
            
            // combo indicator
            if combo > 1 {
                Text("x\(combo) COMBO")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)
            } else {
                Text(" ") // keeps layout stable
                    .font(.system(size: 16))
            }
            
            Spacer()
            
            Button(action: onTap) {
                Circle()
                    .fill(greenMode ? Color.green : Color.white)
                    .frame(width: 210, height: 210)
                    .scaleEffect(btnPressed ? 0.88 : 1.0)
                    .animation(.spring(response: 0.15, dampingFraction: 0.5), value: btnPressed)
                    .overlay(
                        Text(gameActive ? "TAP!" : "START")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.black)
                    )
            }
            .buttonStyle(.plain)
            
            if gameActive {
                Text(greenMode ? "GREEN = DOUBLE POINTS" : "")
                    .font(.system(size: 11))
                    .foregroundColor(.green)
                    .frame(height: 16)
            }
            
            Spacer()
            
            Text("best: \(highScore)")
                .font(.footnote)
                .foregroundColor(Color(white: 0.35))
        }
        .padding()
    }
    
    var endScreen: some View {
        VStack(spacing: 20) {
            Text("TIME'S UP")
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
                Text("taps")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("best: \(highScore)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
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
            Button("play again") {
                restartGame()
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 150, height: 48)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top, 8)
        }
        .padding()
    }
    
    func statBlock(value: String, label: String, highlight: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .foregroundColor(highlight ? .red : .white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .tracking(2)
        }
    }
    
    func onTap() {
        if !gameActive {
            beginGame()
            return
        }
        
        let now = Date()
        if let prev = lastTap, now.timeIntervalSince(prev) < 0.5 {
            combo = min(combo + 1, 5)
        } else {
            combo = 1
        }
        lastTap = now
        
        let pts = greenMode ? 2 : 1
        score += pts * combo
        
        btnPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            btnPressed = false
        }
    }
    
    func beginGame() {
        score = 0
        timeLeft = 10
        combo = 1
        lastTap = nil
        gameOver = false
        gameActive = true
        startColourCycle()
    }
    
    func finish() {
        gameActive = false
        gameOver = true
        colourTimer?.invalidate()
        if score > highScore { highScore = score }
        let loc = LocationService.shared.coordinate
        SessionStore.shared.save(GameSession(mode: .tapFrenzy, score: score, playerName: playerName, latitude: loc.lat, longitude: loc.lon))
    }
    
    func restartGame() {
        score = 0
        timeLeft = 10
        combo = 1
        lastTap = nil
        greenMode = false
        gameOver = false
        gameActive = false
    }
    
    func startColourCycle() {
        colourTimer?.invalidate()
        colourTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                self.greenMode = Bool.random()
            }
        }
    }
}

