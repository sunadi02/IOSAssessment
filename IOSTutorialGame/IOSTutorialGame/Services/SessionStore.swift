import Foundation
import Combine

class SessionStore: ObservableObject {
    
    static let shared = SessionStore()
    
    @Published var sessions: [GameSession] = []
    
    private let key = "gameSessions"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            self.sessions = decoded
        } else {
            self.sessions = []
        }
    }
    
    func save(_ session: GameSession) {
        sessions.append(session)
        persist()
    }
    
    func resetAll() {
        sessions = []
        persist()
    }
    
    func best(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }

    func leaderboard(for mode: GameMode, limit: Int = 10) -> [GameSession] {
        sessions
            .filter { $0.mode == mode }
            .sorted {
                if $0.score == $1.score {
                    return $0.timestamp > $1.timestamp
                }
                return $0.score > $1.score
            }
            .prefix(limit)
            .map { $0 }
    }
    
    func recent(_ count: Int = 10) -> [GameSession] {
        Array(sessions.sorted { $0.timestamp > $1.timestamp }.prefix(count))
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
