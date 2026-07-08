import SwiftUI
import Charts

struct StatsTab: View {
    @ObservedObject var store = SessionStore.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.07).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // personal bests
                        VStack(alignment: .leading, spacing: 12) {
                            Text("personal bests")
                                .font(.system(size: 13))
                                .foregroundColor(Color(white: 0.4))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 10) {
                                bestRow(mode: .tapFrenzy, icon: "hand.tap.fill", accent: .white)
                                bestRow(mode: .lightItUp, icon: "lightbulb.fill", accent: .blue)
                                bestRow(mode: .quizRush, icon: "questionmark.bubble.fill", accent: .orange)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // chart
                        if !store.sessions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("score history")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(white: 0.4))
                                    .padding(.horizontal, 20)
                                
                                Chart(store.recent(20)) { session in
                                    BarMark(
                                        x: .value("game", session.timestamp, unit: .minute),
                                        y: .value("score", session.score)
                                    )
                                    .foregroundStyle(modeColor(session.mode))
                                }
                                .frame(height: 160)
                                .padding(.horizontal, 20)
                                .chartXAxis(.hidden)
                            }
                        }
                        
                        // recent games
                        VStack(alignment: .leading, spacing: 12) {
                            Text("recent games")
                                .font(.system(size: 13))
                                .foregroundColor(Color(white: 0.4))
                                .padding(.horizontal, 20)
                            
                            if store.sessions.isEmpty {
                                Text("no games played yet")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(white: 0.3))
                                    .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(store.recent(10)) { session in
                                        recentRow(session)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    func bestRow(mode: GameMode, icon: String, accent: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(accent == .white ? .black : .white)
                .frame(width: 36, height: 36)
                .background(accent)
                .cornerRadius(8)
            
            Text(mode.rawValue)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(store.best(for: mode))")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(14)
        .background(Color(white: 0.11))
        .cornerRadius(12)
    }
    
    func recentRow(_ session: GameSession) -> some View {
        HStack {
            Text(session.mode.rawValue)
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.6))
            Spacer()
            Text("\(session.score) pts")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
            Text(session.timestamp, style: .relative)
                .font(.system(size: 11))
                .foregroundColor(Color(white: 0.35))
                .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color(white: 0.1))
        .cornerRadius(10)
    }
    
    func modeColor(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .white
        case .lightItUp: return .blue
        case .quizRush: return .orange
        }
    }
}
