import Foundation

struct WardrobeItem: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var category: String
    var color: String
    var season: String
    var occasion: String
    var tags: [String]
    var frontImagePath: String
    var backImagePath: String
    var thumbnailPath: String
    var mimeType: String
    var width: Int?
    var height: Int?
    var byteSize: Int64?
    var contentHash: String

    init(
        id: String = "",
        name: String = "",
        category: String = "",
        color: String = "",
        season: String = "",
        occasion: String = "",
        tags: [String] = [],
        frontImagePath: String = "",
        backImagePath: String = "",
        thumbnailPath: String = "",
        mimeType: String = "image/jpeg",
        width: Int? = nil,
        height: Int? = nil,
        byteSize: Int64? = nil,
        contentHash: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.color = color
        self.season = season
        self.occasion = occasion
        self.tags = tags
        self.frontImagePath = frontImagePath
        self.backImagePath = backImagePath
        self.thumbnailPath = thumbnailPath
        self.mimeType = mimeType
        self.width = width
        self.height = height
        self.byteSize = byteSize
        self.contentHash = contentHash
    }
}
