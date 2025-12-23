import Foundation

enum RepeatType: String, Codable, CaseIterable {
    case none = "Ingen"
    case daily = "Dagligen"
    case weekly = "Varje vecka"
    case monthly = "Varje månad"
}
