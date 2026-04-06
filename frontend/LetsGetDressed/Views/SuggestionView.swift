import SwiftUI

struct SuggestionView: View {
    @EnvironmentObject private var suggestionViewModel: SuggestionViewModel

    var body: some View {
        List {
            Section("Request") {
                TextField("Occasion", text: $suggestionViewModel.occasion)
                TextField("Season", text: $suggestionViewModel.season)
                TextField("Preferred colors (comma separated)", text: $suggestionViewModel.preferredColorsText)

                Text("Shopping suggestions are disabled by default and outfit ideas use only the clothes and accessories already in your wardrobe.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Get Outfit Suggestions") {
                    Task {
                        await suggestionViewModel.loadSuggestions()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if let errorMessage = suggestionViewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section("Suggestions") {
                if suggestionViewModel.suggestedItems.isEmpty && !suggestionViewModel.isLoading {
                    ContentUnavailableView(
                        "No suggestions yet",
                        systemImage: "sparkles",
                        description: Text("Suggestions use only your existing wardrobe items from the local backend.")
                    )
                } else {
                    if !suggestionViewModel.message.isEmpty {
                        Text(suggestionViewModel.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(suggestionViewModel.suggestedItems) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name.isEmpty ? "Unnamed Item" : item.name)
                                .font(.headline)
                            Text(item.category)
                                .font(.subheadline)
                            Text(
                                [item.color, item.season, item.occasion]
                                    .filter { !$0.isEmpty }
                                    .joined(separator: " • ")
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    if !suggestionViewModel.shoppingSuggestions.isEmpty {
                        Text("Shopping suggestions are only shown when explicitly requested.")
                            .font(.caption)
                            .foregroundStyle(.orange)

                        ForEach(suggestionViewModel.shoppingSuggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
        .overlay {
            if suggestionViewModel.isLoading {
                ProgressView("Finding outfits...")
            }
        }
    }
}
