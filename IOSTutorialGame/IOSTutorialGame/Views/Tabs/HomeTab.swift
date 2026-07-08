import SwiftUI

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.07).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ARCADE")
                            .font(.system(size: 42, weight: .black))
                            .foregroundColor(.white)
                        Text("choose a game to play")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.4))
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    VStack(spacing: 14) {
                        NavigationLink(destination: TapFrenzyView()) {
                            ModeButton(title: "Tap Frenzy", desc: "tap as fast as you can in 10 seconds", icon: "hand.tap.fill", accent: .white)
                        }
                        NavigationLink(destination: LightItUpView()) {
                            ModeButton(title: "Light It Up", desc: "hit the glowing card before it goes dark", icon: "lightbulb.fill", accent: .blue)
                        }
                        NavigationLink(destination: QuizRushView()) {
                            ModeButton(title: "Quiz Rush", desc: "10 trivia questions — answer fast", icon: "questionmark.bubble.fill", accent: .orange)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ModeButton: View {
    let title: String
    let desc: String
    let icon: String
    let accent: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accent == .white ? .black : .white)
                .frame(width: 44, height: 44)
                .background(accent)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.45))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(white: 0.35))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(white: 0.13))
        .cornerRadius(14)
    }
}

