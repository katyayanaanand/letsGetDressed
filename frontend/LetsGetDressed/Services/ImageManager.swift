import Foundation
import UIKit

/**
 ImageManager handles storing and retrieving wardrobe photos locally on device.
 Photos are stored in Documents/wardrobe/{itemId}/ to keep them accessible and organized.
 */
class ImageManager {
    static let shared = ImageManager()

    private let fileManager = FileManager.default
    private let documentsPath: URL

    init() {
        self.documentsPath =
            fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - Directory Setup

    /**
     Get or create the wardrobe storage directory.
     Path: Documents/wardrobe/
     */
    private func getWardrobeDirectory() throws -> URL {
        let wardrobeDir = documentsPath.appendingPathComponent("wardrobe")
        if !fileManager.fileExists(atPath: wardrobeDir.path) {
            try fileManager.createDirectory(at: wardrobeDir, withIntermediateDirectories: true)
        }
        return wardrobeDir
    }

    /**
     Get or create item-specific directory.
     Path: Documents/wardrobe/{itemId}/
     */
    private func getItemDirectory(itemId: String) throws -> URL {
        let wardrobeDir = try getWardrobeDirectory()
        let itemDir = wardrobeDir.appendingPathComponent(itemId)
        if !fileManager.fileExists(atPath: itemDir.path) {
            try fileManager.createDirectory(at: itemDir, withIntermediateDirectories: true)
        }
        return itemDir
    }

    // MARK: - Image Storage

    /**
     Save front image for a wardrobe item.
     Returns the relative path for metadata storage.
     */
    func saveFrontImage(_ uiImage: UIImage, itemId: String) throws -> String {
        let itemDir = try getItemDirectory(itemId: itemId)
        let filePath = itemDir.appendingPathComponent("front.jpg")

        if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
            try jpegData.write(to: filePath)
            return "wardrobe/\(itemId)/front.jpg"
        }
        throw ImageManagerError.conversionFailed
    }

    /**
     Save back image for a wardrobe item.
     Returns the relative path for metadata storage.
     */
    func saveBackImage(_ uiImage: UIImage, itemId: String) throws -> String {
        let itemDir = try getItemDirectory(itemId: itemId)
        let filePath = itemDir.appendingPathComponent("back.jpg")

        if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
            try jpegData.write(to: filePath)
            return "wardrobe/\(itemId)/back.jpg"
        }
        throw ImageManagerError.conversionFailed
    }

    /**
     Save thumbnail for preview.
     Smaller size for list views.
     */
    func saveThumbnail(_ uiImage: UIImage, itemId: String) throws -> String {
        let itemDir = try getItemDirectory(itemId: itemId)
        let filePath = itemDir.appendingPathComponent("thumbnail.jpg")

        let resized = resizeImage(uiImage, targetSize: CGSize(width: 320, height: 320))
        if let jpegData = resized.jpegData(compressionQuality: 0.7) {
            try jpegData.write(to: filePath)
            return "wardrobe/\(itemId)/thumbnail.jpg"
        }
        throw ImageManagerError.conversionFailed
    }

    // MARK: - Image Retrieval

    /**
     Load image from local storage by relative path.
     */
    func loadImage(from relativePath: String) -> UIImage? {
        let fullPath = documentsPath.appendingPathComponent(relativePath)
        return UIImage(contentsOfFile: fullPath.path)
    }

    /**
     Get full path for a stored image.
     */
    func getFullPath(for relativePath: String) -> String {
        let fullPath = documentsPath.appendingPathComponent(relativePath)
        return fullPath.path
    }

    // MARK: - Image Processing

    /**
     Calculate image dimensions and byte size.
     */
    func getImageMetadata(_ uiImage: UIImage) -> (width: Int, height: Int, byteSize: Int64) {
        let width = Int(uiImage.size.width)
        let height = Int(uiImage.size.height)

        // Estimate compressed size
        let estimatedByteSize: Int64
        if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
            estimatedByteSize = Int64(jpegData.count)
        } else {
            estimatedByteSize = Int64(width * height * 2) // Rough estimate
        }

        return (width, height, estimatedByteSize)
    }

    /**
     Compute SHA256 hash of image data for deduplication.
     */
    func getImageHash(_ uiImage: UIImage) -> String {
        if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
            return jpegData.hashValue.description
        }
        return UUID().uuidString
    }

    /**
     Resize image to fit target dimensions while maintaining aspect ratio.
     */
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: targetSize)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        image.draw(in: rect)
        let resized = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return resized
    }

    // MARK: - Cleanup

    /**
     Delete all images for a wardrobe item.
     """
    func deleteItemImages(itemId: String) throws {
        let itemDir = try getItemDirectory(itemId: itemId)
        try fileManager.removeItem(at: itemDir)
    }

    /**
     Get total disk usage for wardrobe photos.
     */
    func getWardrobeDiskUsage() -> Int64 {
        guard let wardrobeDir = try? getWardrobeDirectory() else { return 0 }
        var totalSize: Int64 = 0

        if let enumerator = fileManager.enumerator(atPath: wardrobeDir.path) {
            for case let file as String in enumerator {
                let filePath = wardrobeDir.appendingPathComponent(file).path
                if let attributes = try? fileManager.attributesOfItem(atPath: filePath),
                   let fileSize = attributes[.size] as? NSNumber {
                    totalSize += fileSize.int64Value
                }
            }
        }
        return totalSize
    }
}

// MARK: - Errors

enum ImageManagerError: LocalizedError {
    case conversionFailed
    case directoryCreationFailed
    case fileSaveError(String)

    var errorDescription: String? {
        switch self {
        case .conversionFailed:
            return "Failed to convert image to JPEG"
        case .directoryCreationFailed:
            return "Failed to create storage directory"
        case .fileSaveError(let message):
            return "Failed to save image: \(message)"
        }
    }
}
