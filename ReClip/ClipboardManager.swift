//
//  ClipboardManager.swift
//  ReClip
//
//  Created by SAHIL KHATRI on 11/06/25.
//

import AppKit
import Combine

class ClipboardManager: ObservableObject {
    
    // --- CHANGE 1: AUTOMATIC SAVING ---
    // We add a 'didSet' observer. Now, any time the 'history' array is changed,
    // the saveHistory() function will be called automatically.
    @Published var history: [ClipboardItem] = [] {
        didSet {
            saveHistory()
        }
    }
    
    private let pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var lastChangeCount: Int
    
    init() {
        self.lastChangeCount = pasteboard.changeCount
        
        // --- CHANGE 2: LOAD HISTORY ON LAUNCH ---
        // When the app launches, the first thing we do is try to load any saved history.
        loadHistory()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    
    private func checkForChanges() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            if let newText = pasteboard.string(forType: .string) {
                // We add a check to prevent saving empty strings
                if !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                   history.first?.text != newText {
                    let newItem = ClipboardItem(text: newText)
                    history.insert(newItem, at: 0)
                }
            }
        }
    }
    
    func copyToClipboard(text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func clearHistory() {
        history.removeAll()
    }
    func togglePin(for item: ClipboardItem) {
            // Find the index of the item we want to pin/unpin.
            guard let index = history.firstIndex(where: { $0.id == item.id }) else { return }
            
            // Flip the 'isPinned' property from true to false, or false to true.
            history[index].isPinned.toggle()
        }
    
    // --- NEW SECTION: FILE STORAGE ---
    
    // 1. Define a consistent location to save our data file.
    private var storageURL: URL {
        // We use the user's Application Support directory, which is the standard place for this.
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        // We create a subfolder with our app's name to keep things tidy.
        let appDirectory = supportDirectory.appendingPathComponent("ReClip")
        
        // Create the directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        // The final path for our JSON file.
        return appDirectory.appendingPathComponent("history.json")
    }

    // 2. A function to save the history array to the file.
    private func saveHistory() {
        do {
            // Use JSONEncoder to convert our array of ClipboardItems into JSON data.
            let data = try JSONEncoder().encode(history)
            // Write that data to our storage URL.
            try data.write(to: storageURL)
        } catch {
            // If anything goes wrong, we print an error.
            print("Error saving history: \(error.localizedDescription)")
        }
    }

    // 3. A function to load the history from the file.
    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        
        do {
            // Read the raw data from our storage URL.
            let data = try Data(contentsOf: storageURL)
            // Use JSONDecoder to convert the JSON data back into our array of ClipboardItems.
            history = try JSONDecoder().decode([ClipboardItem].self, from: data)
        } catch {
            print("Error loading history: \(error.localizedDescription)")
        }
    }
}
