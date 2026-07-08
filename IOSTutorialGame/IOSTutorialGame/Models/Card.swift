import Foundation

enum CardType {
    case normal, bonus, heart
}

struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
    var type: CardType = .normal
}
