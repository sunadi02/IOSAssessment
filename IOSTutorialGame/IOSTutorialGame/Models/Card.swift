import Foundation

enum CardType {
    case normal, bonus
}

struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
    var type: CardType = .normal
}
