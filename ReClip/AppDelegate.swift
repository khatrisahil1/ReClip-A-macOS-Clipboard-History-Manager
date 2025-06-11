//
//  AppDelegate.swift
//  ReClip
//
//  Created by SAHIL KHATRI on 11/06/25.
//
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            // =================================================================
            

            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ReClip")
            // =================================================================
            
            button.action = #selector(togglePopover(_:))
        }
        
        self.popover = NSPopover()
        self.popover.behavior = .transient
        // The new version passes the 'closePopover' action into the view.
        // The [weak self] is important to prevent memory leaks.
        self.popover.contentViewController = NSHostingController(rootView: ClipboardHistoryView(closePopover: { [weak self] in
            self?.popover.performClose(nil)
        }))
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
}
