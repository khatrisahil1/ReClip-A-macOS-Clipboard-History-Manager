import SwiftUI

// This is the dedicated View for a single row in the list.
struct ClipboardRowView: View {
    let item: ClipboardItem
    let index: Int

    private var sourceAppIcon: NSImage {
        guard let bundleID = item.sourceAppBundleID,
              let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return NSImage(systemSymbolName: "doc", accessibilityDescription: "Default Icon")!
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: sourceAppIcon)
                .resizable().aspectRatio(contentMode: .fit).frame(width: 24, height: 24)

            VStack(alignment: .leading) {
                // This switch correctly displays a text preview or an image thumbnail.
                switch item.content {
                case .text(let text):
                    Text(text).lineLimit(1).truncationMode(.tail)
                case .image:
                    if let nsImage = item.image {
                        Image(nsImage: nsImage)
                            .resizable().scaledToFill().frame(width: 50, height: 28).clipped().cornerRadius(4)
                    } else {
                        Text("Invalid Image").foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            if index < 9 {
                Text("⌘\(index + 1)").foregroundColor(.secondary)
            }

            if item.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundColor(Color(NSColor.controlAccentColor))
                    .padding(.leading, 4)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .cornerRadius(6)
    }
}


// This is the main view for the popover.
struct ClipboardHistoryView: View {

    @StateObject private var clipboardManager = ClipboardManager()
    @State private var searchText = ""
    @State private var selectedItemId: UUID?

    var closePopover: () -> Void = {}
    var openPreferences: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search clipboard...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

            if filteredHistory.isEmpty {
                VStack {
                    Spacer()
                    Text(searchText.isEmpty ? "Your clipboard is empty." : "No results found.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }.frame(maxWidth: .infinity)
            } else {
                List(selection: $selectedItemId) {
                    ForEach(filteredHistory, id: \.element.id) { index, item in
                        ClipboardRowView(item: item, index: index)
                            .tag(item.id)
                            .contextMenu {
                                Button(action: { /* Quick Look will go here */ }) {
                                    Label("Quick Look", systemImage: "eye")
                                }
                                .keyboardShortcut("q", modifiers: .option)
                                
                                Divider()

                                Button(action: { clipboardManager.togglePin(for: item) }) {
                                    Label(item.isPinned ? "Unpin" : "Pin", systemImage: "pin")
                                }
                                
                                Button(role: .destructive, action: { clipboardManager.deleteItem(with: item.id) }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .onChange(of: selectedItemId) { _, newId in
                    if newId != nil {
                        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
                    }
                }
                .keyboardShortcut("p", modifiers: .option) {
                    if let selectedId = selectedItemId, let item = clipboardManager.history.first(where: { $0.id == selectedId }) {
                        clipboardManager.togglePin(for: item)
                    }
                }
                .keyboardShortcut(.delete, modifiers: .option) {
                    if let selectedId = selectedItemId {
                        clipboardManager.deleteItem(with: selectedId)
                    }
                }
                .onSubmit(of: .return) {
                    if let selectedId = selectedItemId, let item = clipboardManager.history.first(where: { $0.id == selectedId }) {
                        clipboardManager.copyItemToClipboard(item: item)
                        closePopover()
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: 0) {
                Divider()
                HStack {
                    Text("\(clipboardManager.history.count) items").font(.caption)
                    Spacer()
                    Button("Preferences…") { openPreferences() }
                    Button("Clear") { clipboardManager.clearHistory() }
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                }
                .padding(10)
            }
        }
        .frame(width: 380, height: 450)
    }

    var filteredHistory: [(index: Int, element: ClipboardItem)] {
        let filtered = searchText.isEmpty ? clipboardManager.history : clipboardManager.history.filter {
            $0.previewText.lowercased().contains(searchText.lowercased())
        }

        let sorted = filtered.sorted { (item1, item2) -> Bool in
            if item1.isPinned && !item2.isPinned { return true }
            return false
        }

        // The .map function ensures the return type has the correct (index:, element:) labels.
        // This is the line that fixes all the compiler errors.
        return sorted.enumerated().map { (index, element) in
            return (index: index, element: element)
        }
    }
}

// This extension is required for the conditional .if modifier
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

// The preview provider is required for the file to compile
struct ClipboardHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardHistoryView()
    }
}
