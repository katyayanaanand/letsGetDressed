import Foundation

final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL = URL(string: "http://localhost:8080")!) {
        self.baseURL = baseURL
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func fetchWardrobe() async throws -> [WardrobeItem] {
        let url = baseURL.appendingPathComponent("/api/wardrobe")
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response)
        return try decoder.decode([WardrobeItem].self, from: data)
    }

    func fetchWardrobeItem(id: String) async throws -> WardrobeItem {
        let url = baseURL.appendingPathComponent("/api/wardrobe/\(id)")
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response)
        return try decoder.decode(WardrobeItem.self, from: data)
    }

    func createWardrobeItem(_ item: WardrobeItem) async throws -> WardrobeItem {
        let url = baseURL.appendingPathComponent("/api/wardrobe")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(item)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response)
        return try decoder.decode(WardrobeItem.self, from: data)
    }

    func fetchSuggestions(request suggestionRequest: OutfitSuggestionRequest) async throws -> OutfitSuggestionResponse {
        let url = baseURL.appendingPathComponent("/api/suggestions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(suggestionRequest)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response)
        return try decoder.decode(OutfitSuggestionResponse.self, from: data)
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIClientError.httpError(httpResponse.statusCode)
        }
    }
}

enum APIClientError: LocalizedError {
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server response was invalid."
        case .httpError(let statusCode):
            return "The server returned status code \(statusCode)."
        }
    }
}
