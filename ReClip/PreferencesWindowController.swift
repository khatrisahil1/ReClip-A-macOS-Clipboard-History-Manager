//
//  PreferencesWindowController.swift
//  ReClip
//
//  Created by SAHIL KHATRI on 21/06/25.
//


// In PreferencesWindowController.swift

import Cocoa
import SwiftUI

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    // A shared instance to ensure we only ever create one preferences window.
    static let shared = PreferencesWindowController()

    // We create the window programmatically in the initializer.
    private init() {
        // 1. Create the window.
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ReClip Preferences"
        window.center() // Open the window in the center of the screen.

        // 2. Set the content to our SwiftUI view.
        // We use NSHostingController again to bridge SwiftUI and AppKit.
        window.contentViewController = NSHostingController(rootView: PreferencesView())

        // 3. Set this class as the window controller.
        super.init(window: window)
        
        // 4. Set the delegate to self to receive window events.
        window.delegate = self
    }

    // This is required when subclassing NSWindowController.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This delegate method ensures that when the user closes the window,
    // it properly releases from memory.
    func windowWillClose(_ notification: Notification) {
        // This is a bit of a workaround to allow the window to be re-opened
        // after being closed. We effectively hide it instead of fully closing it.
        window?.orderOut(nil)
    }

    // A simple function to show the window.
    func show() {
        // The 'makeKeyAndOrderFront' method makes the window visible and active.
        window?.makeKeyAndOrderFront(nil)
        // This brings the app to the foreground, which is important for a settings window.
        NSApp.activate(ignoringOtherApps: true)
    }
}