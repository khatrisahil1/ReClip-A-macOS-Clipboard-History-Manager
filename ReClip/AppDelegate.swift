import Cocoa
import SwiftUI

// This file is our main entry point and does not have @main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ReClip")
            button.action = #selector(togglePopover(_:))
        }
        
        self.popover = NSPopover()
        self.popover.behavior = .transient
        
        // --- CHANGE 1: We now pass BOTH actions into our SwiftUI view ---
        // This 'rootView' now knows how to close itself and how to open preferences.
        let rootView = ClipboardHistoryView(
            closePopover: { [weak self] in
                self?.popover.performClose(nil)
            },
            openPreferences: { [weak self] in
                self?.openPreferencesWindow()
            }
        )
        self.popover.contentViewController = NSHostingController(rootView: rootView)
        self.popover.contentSize = NSSize(width: 380, height: 450)
        
        hotkeyManager = HotkeyManager { [weak self] in
            self?.togglePopover(nil)
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.becomeKey()
        }
    }
    
    // --- CHANGE 2: This is the new function that shows the window ---
    @objc func openPreferencesWindow() {
        // We close the main popover first for a cleaner user experience.
        self.popover.performClose(nil)
        
        // We call the .show() method on the shared instance of our window controller.
        PreferencesWindowController.shared.show()
    }
}
