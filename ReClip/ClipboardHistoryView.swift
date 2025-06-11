import SwiftUI

struct ClipboardHistoryView: View {
    
    @StateObject private var clipboardManager = ClipboardManager()
    @State private var searchText = ""
    @State private var hoveredItemId: UUID?
    
    var closePopover: () -> Void = {}
    
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredHistory.enumerated()), id: \.element.id) { index, item in
                            Button(action: {
                                clipboardManager.copyToClipboard(text: item.text)
                                closePopover()
                            }) {
                                HStack {
                                    Text(item.text)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if index < 9 {
                                        Text("⌘\(index + 1)")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.white.opacity(0.05))
                                            .cornerRadius(4)
                                    }
                                    
                                    Button(action: {
                                        clipboardManager.togglePin(for: item)
                                    }) {
                                        Image(systemName: item.isPinned ? "pin.fill" : "pin")
                                            .foregroundColor(item.isPinned ? Color(NSColor.controlAccentColor) : .secondary)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.leading, 4)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                .background(hoveredItemId == item.id ? Color.white.opacity(0.1) : Color.clear)
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .onHover { isHovering in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    if isHovering { self.hoveredItemId = item.id }
                                    else { self.hoveredItemId = nil }
                                }
                            }
                            .if(index < 9) { view in
                                view.keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
                            }
                            
                            if item.id != filteredHistory.last?.id {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color.white.opacity(0.1))
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onChange(of: hoveredItemId) { oldId, newId in
                    if newId != nil {
                        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            VStack(spacing: 0) {
                Divider()
                HStack {
                    Text("\(clipboardManager.history.count) items")
                        .font(.caption)
                    Spacer()
                    Button("Clear") { clipboardManager.clearHistory() }
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                }
                .padding(10)
            }
        }
        .frame(width: 380, height: 450)
    }
    
    // --- THIS IS THE FINAL CHANGE ---
    var filteredHistory: [ClipboardItem] {
        let filtered = searchText.isEmpty ? clipboardManager.history : clipboardManager.history.filter {
            $0.text.lowercased().contains(searchText.lowercased())
        }
        
        // Now, sort the filtered list to bring pinned items to the top.
        return filtered.sorted { (item1, item2) -> Bool in
            // The sorting rule: if item1 is pinned and item2 is not, item1 comes first.
            if item1.isPinned && !item2.isPinned {
                return true
            }
            // In all other cases (both pinned, both unpinned, or item1 unpinned and item2 pinned),
            // we don't reorder them, preserving the original chronological sort.
            return false
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct ClipboardHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardHistoryView()
    }
}
