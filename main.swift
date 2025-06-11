//
//  main.swift
//  ReClip
//
//  Created by SAHIL KHATRI on 12/06/25.
//

// In main.swift

import Cocoa

// 1. Create an instance of our AppDelegate.
let delegate = AppDelegate()

// 2. Assign it as the delegate for the shared NSApplication instance.
// This is the crucial step that ensures our AppDelegate stays alive.
NSApplication.shared.delegate = delegate

// 3. Run the main application loop.
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
