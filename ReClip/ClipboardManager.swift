import AppKit
import Combine

class ClipboardManager: ObservableObject {
    
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
        loadHistory()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    func deleteItem(with id: UUID) {
            // This finds and removes any item from the history array whose ID matches.
            history.removeAll(where: { $0.id == id })
        }
    // --- THIS IS THE FULLY UPGRADED FUNCTION ---
    private func checkForChanges() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            let frontmostApp = NSWorkspace.shared.frontmostApplication
            
            // 1. First, we check for image data on the clipboard.
            // .tiff is a common format for clipboard images.
            if let imageData = pasteboard.data(forType: .tiff) {
                // To prevent duplicates, we could add more advanced checking here in the future.
                // For now, we create a new image item.
                let newItem = ClipboardItem(
                    content: .image(imageData),
                    sourceAppName: frontmostApp?.localizedName,
                    sourceAppBundleID: frontmostApp?.bundleIdentifier
                )
                history.insert(newItem, at: 0)

            // 2. If no image is found, we check for text, just like before.
            } else if let newText = pasteboard.string(forType: .string) {
                if !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                   history.first?.previewText != newText {
                    
                    let newItem = ClipboardItem(
                        content: .text(newText),
                        sourceAppName: frontmostApp?.localizedName,
                        sourceAppBundleID: frontmostApp?.bundleIdentifier
                    )
                    history.insert(newItem, at: 0)
                }
            }
        }
    }
    
    // --- THIS FUNCTION REPLACES THE OLD copyToClipboard ---
    // It can handle any type of ClipboardItem.
    func copyItemToClipboard(item: ClipboardItem) {
        pasteboard.clearContents()
        
        switch item.content {
        case .text(let text):
            pasteboard.setString(text, forType: .string)
        case .image(let data):
            pasteboard.setData(data, forType: .tiff)
        }
    }
    
    func clearHistory() {
        history.removeAll()
    }
    
    func togglePin(for item: ClipboardItem) {
        guard let index = history.firstIndex(where: { $0.id == item.id }) else { return }
        history[index].isPinned.toggle()
    }
    
    // --- NO CHANGES NEEDED FOR SAVING AND LOADING ---
    // Our Codable setup automatically handles the new enum!
    
    private var storageURL: URL {
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = supportDirectory.appendingPathComponent("ReClip")
        
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return appDirectory.appendingPathComponent("history.json")
    }

    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: storageURL)
        } catch {
            print("Error saving history: \(error.localizedDescription)")
        }
    }

    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: storageURL)
            history = try JSONDecoder().decode([ClipboardItem].self, from: data)
        } catch {
            print("Error loading history: \(error.localizedDescription)")
        }
    }
}
