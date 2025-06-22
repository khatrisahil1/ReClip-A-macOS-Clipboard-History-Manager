//
//  MetadataView.swift
//  ReClip
//
//  Created by SAHIL KHATRI on 21/06/25.
//


// In MetadataView.swift

import SwiftUI

struct MetadataView: View {
    // This view receives the item to display and the manager to perform actions.
    let item: ClipboardItem
    let manager: ClipboardManager
    
    // A helper to get the application's icon.
    private var sourceAppIcon: NSImage {
        guard let bundleID = item.sourceAppBundleID,
              let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return NSImage(systemSymbolName: "doc", accessibilityDescription: "Default Icon")!
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with App Icon and Name
            HStack {
                Image(nsImage: sourceAppIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                
                Text(item.sourceAppName ?? "Unknown Application")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            // --- THIS IS THE FIX ---
            // A new preview area that can show either Text or an Image.
            VStack {
                switch item.content {
                case .text(let text):
                    // If it's text, we show it in a scrollable view.
                    ScrollView {
                        Text(text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                case .image(let data):
                    // If it's an image, we display the image.
                    if let nsImage = NSImage(data: data) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Text("Invalid Image Data")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(8)
            .frame(maxHeight: 200) // Give the preview a max height to prevent it from being too large.
            
            // Action buttons and hints
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { manager.togglePin(for: item) }) {
                    Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.fill" : "pin")
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 250)
    }
}
