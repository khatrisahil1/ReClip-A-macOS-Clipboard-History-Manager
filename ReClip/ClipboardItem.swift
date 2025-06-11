//
//  ClipboardItem.swift
//  ReClip
//
//  Created by SAHIL KHATRI on 11/06/25.
//

import Foundation

struct ClipboardItem: Identifiable, Equatable, Codable {
    
    let id: UUID
    let text: String
    
    // --- THIS IS THE NEW PROPERTY ---
    // We add a variable to track if an item is pinned.
    // We give it a default value of 'false' so all existing and new items
    // will be unpinned by default.
    var isPinned: Bool = false
    
    init(text: String) {
        self.id = UUID()
        self.text = text
    }
    
    // We need to add a second init to handle decoding from the file,
    // as our custom init breaks the automatic Codable synthesis for this case.
    // This ensures both new and loaded items work correctly.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        // For files saved before pinning was a feature, isPinned might not exist.
        // We use .decodeIfPresent and provide 'false' as a fallback.
        self.isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }
}
