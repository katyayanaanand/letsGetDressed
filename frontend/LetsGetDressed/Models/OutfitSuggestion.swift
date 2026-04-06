import Foundation

struct OutfitSuggestionRequest: Codable {
    var occasion: String
    var season: String
    var preferredColors: [String]
    var allowShoppingSuggestions: Bool

    init(
        occasion: String = "",
        season: String = "",
        preferredColors: [String] = [],
        allowShoppingSuggestions: Bool = false
    ) {
        self.occasion = occasion
        self.season = season
        self.preferredColors = preferredColors
        self.allowShoppingSuggestions = allowShoppingSuggestions
    }
}

struct OutfitSuggestionResponse: Codable {
    var suggestedItems: [WardrobeItem]
    var shoppingSuggestions: [String]
    var message: String

    init(
        suggestedItems: [WardrobeItem] = [],
        shoppingSuggestions: [String] = [],
        message: String = ""
    ) {
        self.suggestedItems = suggestedItems
        self.shoppingSuggestions = shoppingSuggestions
        self.message = message
    }
}
