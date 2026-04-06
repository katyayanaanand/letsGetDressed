import Foundation
import UIKit

@MainActor
final class WardrobeViewModel: ObservableObject {
    @Published var items: [WardrobeItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var draftItem = WardrobeItem()

    @Published var showCamera = false
    @Published var showGallery = false
    @Published var cameraMode: CameraMode = .front
    @Published var frontImage: UIImage?
    @Published var backImage: UIImage?
    @Published var uploadProgress: Double = 0

    private let apiClient: APIClient
    private let imageManager = ImageManager.shared

    enum CameraMode {
        case front
        case back
    }

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Wardrobe Loading

    func loadWardrobe() async {
        isLoading = true
        errorMessage = nil

        do {
            items = try await apiClient.fetchWardrobe()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Image Capture

    func handleFrontImageCapture(_ image: UIImage) {
        frontImage = image
        draftItem.frontImagePath = "temp_front"
        showCamera = false
    }

    func handleBackImageCapture(_ image: UIImage) {
        backImage = image
        draftItem.backImagePath = "temp_back"
        showCamera = false
    }

    func handleGallerySelection(_ image: UIImage) {
        if cameraMode == .front {
            handleFrontImageCapture(image)
        } else {
            handleBackImageCapture(image)
        }
        showGallery = false
    }

    // MARK: - Item Creation

    func addItem() async {
        errorMessage = nil
        isLoading = true

        defer { isLoading = false }

        do {
            // Validate we have at least front image
            guard let frontImage = frontImage else {
                errorMessage = "Front image is required"
                return
            }

            // Generate unique item ID
            let itemId = UUID().uuidString

            // Save images locally
            let frontPath = try imageManager.saveFrontImage(frontImage, itemId: itemId)
            let backPath: String?
            if let backImage = backImage {
                backPath = try imageManager.saveBackImage(backImage, itemId: itemId)
            } else {
                backPath = nil
            }

            // Save thumbnail
            let thumbnailPath = try imageManager.saveThumbnail(frontImage, itemId: itemId)

            // Get image metadata
            let (width, height, byteSize) = imageManager.getImageMetadata(frontImage)
            let contentHash = imageManager.getImageHash(frontImage)

            // Build item with paths
            var item = draftItem
            item.id = itemId
            item.frontImagePath = frontPath
            item.backImagePath = backPath ?? ""
            item.thumbnailPath = thumbnailPath
            item.width = width
            item.height = height
            item.byteSize = byteSize
            item.mimeType = "image/jpeg"
            item.contentHash = contentHash

            // Upload to backend
            let created = try await apiClient.createWardrobeItem(item)
            items.append(created)

            // Reset form
            draftItem = WardrobeItem()
            frontImage = nil
            backImage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Image Display

    func getImageForItem(_ item: WardrobeItem) -> UIImage? {
        if !item.frontImagePath.isEmpty {
            return imageManager.loadImage(from: item.frontImagePath)
        }
        if !item.backImagePath.isEmpty {
            return imageManager.loadImage(from: item.backImagePath)
        }
        return nil
    }

    func getThumbnailForItem(_ item: WardrobeItem) -> UIImage? {
        if !item.thumbnailPath.isEmpty {
            return imageManager.loadImage(from: item.thumbnailPath)
        }
        return getImageForItem(item)
    }

    // MARK: - Permissions

    func requestCameraPermission() async -> Bool {
        await CameraPermissionManager.shared.requestCameraPermission()
    }

    func isCameraAvailable() -> Bool {
        CameraPermissionManager.shared.checkCameraAvailable()
    }
}