import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TabView {
                WardrobeListView()
                    .tabItem {
                        Label("Wardrobe", systemImage: "hanger")
                    }

                SuggestionView()
                    .tabItem {
                        Label("Suggestions", systemImage: "sparkles")
                    }
            }
            .navigationTitle("Let's Get Dressed")
        }
    }
}