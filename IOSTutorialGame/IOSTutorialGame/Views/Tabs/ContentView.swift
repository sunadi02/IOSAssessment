import SwiftUI

struct ContentView: View {
    @StateObject private var challengeRouter = ChallengeRouter.shared
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller.fill")
                }
            
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Color(red: 0.12, green: 0.48, blue: 0.88))
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .fullScreenCover(item: $challengeRouter.activeChallenge) { challenge in
            ChallengeGameHostView(game: challenge)
        }
    }
}
