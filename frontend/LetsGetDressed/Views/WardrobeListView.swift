import SwiftUI

struct WardrobeListView: View {
    @EnvironmentObject private var viewModel: WardrobeViewModel

    var body: some View {
        NavigationStack {
            if viewModel.items.isEmpty && !viewModel.isLoading {
                VStack(spacing: 20) {
                    ContentUnavailableView(
                        "No wardrobe items yet",
                        systemImage: "tshirt",
                        description: Text("Scan your first clothing item to get started")
                    )

                    NavigationLink("Add Your First Item") {
                        AddItemDetailView()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                                .padding()
                        }
                    }

                    Section("Your Wardrobe (\(viewModel.items.count))") {
                        ForEach(viewModel.items) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                WardrobeItemRow(item: item, viewModel: viewModel)
                            }
                        }
                    }

                    Section {
                        NavigationLink("Add New Item", systemImage: "plus.circle") {
                            AddItemDetailView()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading wardrobe...")
                    .tint(.blue)
            }
        }
        .task {
            if viewModel.items.isEmpty {
                await viewModel.loadWardrobe()
            }
        }
        .refreshable {
            await viewModel.loadWardrobe()
        }
    }
}

// MARK: - Item Row

struct WardrobeItemRow: View {
    let item: WardrobeItem
    let viewModel: WardrobeViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let image = viewModel.getThumbnailForItem(item) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.gray.opacity(0.7))
                    )
            }

            // Item details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.isEmpty ? "Untitled" : item.name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if !item.category.isEmpty {
                        Label(item.category, systemImage: "tag")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    if !item.color.isEmpty {
                        Label(item.color, systemImage: "paintbrush.fill")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    if !item.occasion.isEmpty {
                        Label(item.occasion, systemImage: "calendar")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.gray.opacity(0.5))
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Add Item View (Full Screen)

struct AddItemDetailView: View {
    @EnvironmentObject private var viewModel: WardrobeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            AddItemView()
                .navigationTitle("Add to Wardrobe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .onChange(of: viewModel.items.count) { _, newCount in
                    // Dismiss after successful add
                    if !viewModel.draftItem.name.isEmpty {
                        // Reset happens after successful add
                        dismiss()
                    }
                }
        }
    }
}

// MARK: - Item Detail View

struct ItemDetailView: View {
    let item: WardrobeItem
    @EnvironmentObject private var viewModel: WardrobeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Front image
                if let image = viewModel.getImageForItem(item) {
                    VStack(alignment: .leading) {
                        Text("Front")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    }
                }

                // Details section
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow("Name", item.name)
                    DetailRow("Category", item.category)
                    DetailRow("Color", item.color)
                    DetailRow("Season", item.season)
                    DetailRow("Occasion", item.occasion)

                    if !item.tags.isEmpty {
                        DetailRow("Tags", item.tags.joined(separator: ", "))
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views

struct DetailRow: View {
    let label: String
    let value: String

    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        if !value.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}