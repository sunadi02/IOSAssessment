import Foundation

enum GameMode: String, Codable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
}

struct GameSession: Codable, Identifiable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let playerName: String
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    
    init(mode: GameMode, score: Int, playerName: String = "Player", latitude: Double = 0, longitude: Double = 0) {
        self.id = UUID()
        self.mode = mode
        self.score = score
        self.playerName = playerName.isEmpty ? "Player" : playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.timestamp = Date()
        self.latitude = latitude
        self.longitude = longitude
    }

    enum CodingKeys: String, CodingKey {
        case id, mode, score, playerName, timestamp, latitude, longitude
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        mode = try container.decode(GameMode.self, forKey: .mode)
        score = try container.decode(Int.self, forKey: .score)
        playerName = try container.decodeIfPresent(String.self, forKey: .playerName)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmptyOrDefault("Player") ?? "Player"
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(mode, forKey: .mode)
        try container.encode(score, forKey: .score)
        try container.encode(playerName, forKey: .playerName)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

private extension String {
    func nonEmptyOrDefault(_ defaultValue: String) -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultValue : trimmed
    }
}
