import Foundation
import AppKit

// --- FIX 1: The enum is now Equatable AND Codable ---
enum ClipContent: Equatable, Codable {
    case text(String)
    case image(Data)
}

struct ClipboardItem: Identifiable, Equatable, Codable {
    
    // --- FIX 2: The 'id' no longer has a default value here ---
    let id: UUID
    let content: ClipContent
    
    var isPinned: Bool = false
    let sourceAppName: String?
    let sourceAppBundleID: String?
    
    // Helper property for UI text preview
    var previewText: String {
        switch content {
        case .text(let string):
            return string
        case .image:
            return "Image"
        }
    }
    
    // Helper property to get an NSImage from data
    var image: NSImage? {
        switch content {
        case .text:
            return nil
        case .image(let data):
            return NSImage(data: data)
        }
    }
    
    // --- FIX 2 (cont.): We create the ID in our custom initializer ---
    // This initializer is for creating brand new items.
    init(content: ClipContent, sourceAppName: String?, sourceAppBundleID: String?) {
        self.id = UUID() // The new, unique ID is created here.
        self.content = content
        self.sourceAppName = sourceAppName
        self.sourceAppBundleID = sourceAppBundleID
    }

    // This initializer is for loading saved items from the JSON file.
    // It makes sure we can still load old data that doesn't have the new properties.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // It decodes the saved ID from the file instead of creating a new one.
        self.id = try container.decode(UUID.self, forKey: .id)
        self.content = try container.decode(ClipContent.self, forKey: .content)
        self.isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        self.sourceAppName = try container.decodeIfPresent(String.self, forKey: .sourceAppName)
        self.sourceAppBundleID = try container.decodeIfPresent(String.self, forKey: .sourceAppBundleID)
    }
    
    // We explicitly list all properties for Codable to use.
    private enum CodingKeys: String, CodingKey {
        case id, content, isPinned, sourceAppName, sourceAppBundleID
    }
}
