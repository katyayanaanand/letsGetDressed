import Foundation

@MainActor
final class SuggestionViewModel: ObservableObject {
    @Published var occasion = ""
    @Published var season = ""
    @Published var preferredColorsText = ""
    @Published var suggestedItems: [WardrobeItem] = []
    @Published var shoppingSuggestions: [String] = []
    @Published var message = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func loadSuggestions() async {
        isLoading = true
        errorMessage = nil

        do {
            let request = OutfitSuggestionRequest(
                occasion: occasion,
                season: season,
                preferredColors: preferredColors,
                allowShoppingSuggestions: false
            )
            let response = try await apiClient.fetchSuggestions(request: request)
            suggestedItems = response.suggestedItems
            shoppingSuggestions = response.shoppingSuggestions
            message = response.message
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private var preferredColors: [String] {
        preferredColorsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
