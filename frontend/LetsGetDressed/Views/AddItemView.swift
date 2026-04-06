import SwiftUI

struct AddItemView: View {
    @EnvironmentObject private var viewModel: WardrobeViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Image capture section
            imageCapturSection

            // Item details
            Form {
                Section("Item Details") {
                    TextField("Name", text: $viewModel.draftItem.name)
                    Picker("Category", selection: $viewModel.draftItem.category) {
                        Text("Select...").tag("")
                        Text("Top").tag("Top")
                        Text("Bottom").tag("Bottom")
                        Text("Dress").tag("Dress")
                        Text("Jacket").tag("Jacket")
                        Text("Shoes").tag("Shoes")
                        Text("Accessory").tag("Accessory")
                    }
                    TextField("Color", text: $viewModel.draftItem.color)
                }

                Section("Occasion & Season") {
                    Picker("Season", selection: $viewModel.draftItem.season) {
                        Text("Select...").tag("")
                        Text("Spring").tag("Spring")
                        Text("Summer").tag("Summer")
                        Text("Fall").tag("Fall")
                        Text("Winter").tag("Winter")
                        Text("All Year").tag("All Year")
                    }
                    Picker("Occasion", selection: $viewModel.draftItem.occasion) {
                        Text("Select...").tag("")
                        Text("Casual").tag("Casual")
                        Text("Work").tag("Work")
                        Text("Party").tag("Party")
                        Text("Sports").tag("Sports")
                        Text("Wedding").tag("Wedding")
                    }
                }

                Section("Tags") {
                    TextField("Tags (comma separated)", text: tagsBinding)
                }
            }

            // Save button
            Button(action: saveItem) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Save to Wardrobe")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isFormValid() || viewModel.isLoading)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Spacer()
        }
    }

    // MARK: - Image Capture Section

    private var imageCapturSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Front image
                VStack {
                    if let image = viewModel.frontImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 120)
                            .overlay(
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.title3)
                                    Text("Front")
                                        .font(.caption)
                                }
                                .foregroundStyle(.gray)
                            )
                    }

                    Menu {
                        Button(action: captureFront) {
                            Label("Take Photo", systemImage: "camera")
                        }
                        Button(action: selectFromGalleryFront) {
                            Label("Choose from Library", systemImage: "photo")
                        }
                    } label: {
                        Text("Capture Front")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                // Back image
                VStack {
                    if let image = viewModel.backImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 120)
                            .overlay(
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.title3)
                                    Text("Back (Optional)")
                                        .font(.caption)
                                }
                                .foregroundStyle(.gray)
                            )
                    }

                    Menu {
                        Button(action: captureBack) {
                            Label("Take Photo", systemImage: "camera")
                        }
                        Button(action: selectFromGalleryBack) {
                            Label("Choose from Library", systemImage: "photo")
                        }
                    } label: {
                        Text("Capture Back")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $viewModel.showCamera) {
            CameraCapture(
                onCapture: handleCameraCapture,
                onCancel: { viewModel.showCamera = false }
            )
        }
        .sheet(isPresented: $viewModel.showGallery) {
            PhotoGalleryPicker(
                onSelect: viewModel.handleGallerySelection,
                onCancel: { viewModel.showGallery = false }
            )
        }
    }

    // MARK: - Helpers

    private func isFormValid() -> Bool {
        !viewModel.draftItem.name.isEmpty
            && !viewModel.draftItem.category.isEmpty
            && viewModel.frontImage != nil
    }

    private func captureFront() {
        viewModel.cameraMode = .front
        viewModel.showCamera = true
    }

    private func captureBack() {
        viewModel.cameraMode = .back
        viewModel.showCamera = true
    }

    private func selectFromGalleryFront() {
        viewModel.cameraMode = .front
        viewModel.showGallery = true
    }

    private func selectFromGalleryBack() {
        viewModel.cameraMode = .back
        viewModel.showGallery = true
    }

    private func handleCameraCapture(_ image: UIImage) {
        if viewModel.cameraMode == .front {
            viewModel.handleFrontImageCapture(image)
        } else {
            viewModel.handleBackImageCapture(image)
        }
    }

    private func saveItem() {
        Task {
            await viewModel.addItem()
        }
    }

    private var tagsBinding: Binding<String> {
        Binding(
            get: {
                viewModel.draftItem.tags.joined(separator: ", ")
            },
            set: { newValue in
                viewModel.draftItem.tags = newValue
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
        )
    }
}