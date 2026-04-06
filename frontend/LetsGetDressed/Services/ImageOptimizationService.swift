import Foundation

struct OptimizedImageMetadata {
    let frontImagePath: String
    let backImagePath: String
    let thumbnailPath: String
    let mimeType: String
    let width: Int
    let height: Int
    let byteSize: Int64
    let contentHash: String
}

struct ImageOptimizationService {
    private let maxDimension = 1600
    private let thumbnailDimension = 320

    func optimizePlaceholder(frontImagePath: String, backImagePath: String) -> OptimizedImageMetadata {
        let normalizedFront = normalize(path: frontImagePath)
        let normalizedBack = normalize(path: backImagePath)
        let selectedPath = normalizedFront.isEmpty ? normalizedBack : normalizedFront
        let thumbnailPath = makeThumbnailPath(from: selectedPath)
        let estimatedWidth = min(maxDimension, 1200)
        let estimatedHeight = min(maxDimension, 1200)
        let estimatedBytes = estimateCompressedByteSize(width: estimatedWidth, height: estimatedHeight, mimeType: "image/jpeg")
        let hashSource = [normalizedFront, normalizedBack, thumbnailPath, String(estimatedBytes)].joined(separator: "|")

        return OptimizedImageMetadata(
            frontImagePath: normalizedFront,
            backImagePath: normalizedBack,
            thumbnailPath: thumbnailPath,
            mimeType: preferredMimeType(for: selectedPath),
            width: estimatedWidth,
            height: estimatedHeight,
            byteSize: estimatedBytes,
            contentHash: simpleHash(for: hashSource)
        )
    }

    func estimateCompressedByteSize(width: Int, height: Int, mimeType: String) -> Int64 {
        let pixels = max(width, 1) * max(height, 1)
        let bytesPerPixel = mimeType == "image/heic" ? 0.35 : 0.55
        return Int64(Double(pixels) * bytesPerPixel)
    }

    func targetDimensions(for width: Int, height: Int) -> (width: Int, height: Int) {
        guard width > 0, height > 0 else {
            return (maxDimension, maxDimension)
        }

        let largestSide = max(width, height)
        guard largestSide > maxDimension else {
            return (width, height)
        }

        let scale = Double(maxDimension) / Double(largestSide)
        return (
            width: max(1, Int(Double(width) * scale)),
            height: max(1, Int(Double(height) * scale))
        )
    }

    func thumbnailDimensions(for width: Int, height: Int) -> (width: Int, height: Int) {
        guard width > 0, height > 0 else {
            return (thumbnailDimension, thumbnailDimension)
        }

        let largestSide = max(width, height)
        let scale = Double(thumbnailDimension) / Double(largestSide)
        return (
            width: max(1, Int(Double(width) * scale)),
            height: max(1, Int(Double(height) * scale))
        )
    }

    func preferredMimeType(for path: String) -> String {
        let lowered = path.lowercased()
        if lowered.hasSuffix(".heic") || lowered.hasSuffix(".heif") {
            return "image/heic"
        }
        return "image/jpeg"
    }

    private func normalize(path: String) -> String {
        path.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func makeThumbnailPath(from path: String) -> String {
        guard !path.isEmpty else {
            return "thumbnails/placeholder-thumb.jpg"
        }

        let url = URL(fileURLWithPath: path)
        let fileName = url.deletingPathExtension().lastPathComponent
        return "thumbnails/\(fileName)-thumb.jpg"
    }

    private func simpleHash(for value: String) -> String {
        let hash = value.utf8.reduce(UInt64(5381)) { partialResult, byte in
            ((partialResult << 5) &+ partialResult) &+ UInt64(byte)
        }
        return String(hash, radix: 16)
    }
}

/*
 Least-space local scanning contract:
 - Capture or import front/back clothing images locally on iPhone or Mac.
 - Resize large originals so the longest side is capped (for example, 1600 px).
 - Prefer HEIC when available locally; otherwise compress to JPEG.
 - Create a small thumbnail for list rendering.
 - Persist optimized files on disk, not as raw database blobs.
 - Store only file paths plus metadata such as width, height, mimeType, byteSize, and contentHash.
 - Use content hashes to detect duplicates and avoid saving multiple copies of the same optimized image.
 - Original full-resolution images should be discarded after optimization unless the user explicitly chooses to retain them.
 */