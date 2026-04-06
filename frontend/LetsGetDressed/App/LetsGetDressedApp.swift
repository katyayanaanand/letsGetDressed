import SwiftUI

@main
struct LetsGetDressedApp: App {
    @StateObject private var wardrobeViewModel = WardrobeViewModel()
    @StateObject private var suggestionViewModel = SuggestionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(wardrobeViewModel)
                .environmentObject(suggestionViewModel)
        }
    }
}