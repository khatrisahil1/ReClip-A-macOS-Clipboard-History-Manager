//
//  HotkeyManager.swift
//  ReClip
//
//  Created by SAHIL KHATRI on 12/06/25.
//

import Foundation
import Carbon

private func hotKeyHandler(eventHandlerCallRef: EventHandlerCallRef?, event: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    guard let userData = userData else { return noErr }
    let hotkeyManager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()

    hotkeyManager.onHotkeyPressed()
    
    return noErr
}


class HotkeyManager {
    
    var onHotkeyPressed: () -> Void
    
    private var hotkeyRef: EventHotKeyRef?

    init(onHotkeyPressed: @escaping () -> Void) {
        self.onHotkeyPressed = onHotkeyPressed
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), hotKeyHandler, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), nil)
        
        // =================================================================
        // THIS IS THE FIX:
        // The signature string is now exactly four characters long.
        let hotKeyID = EventHotKeyID(signature: "CLIP".fourChar!, id: 1)
        // =================================================================
        
        let keyCode = UInt32(kVK_ANSI_V)
        let modifiers = UInt32(cmdKey | optionKey)
        
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotkeyRef)
    }
    
    deinit {
        if let hotkeyRef = hotkeyRef {
            UnregisterEventHotKey(hotkeyRef)
        }
    }
}

extension String {
    var fourChar: FourCharCode? {
        guard self.count == 4 else { return nil }
        return self.utf16.reduce(0, {$0 << 8 + FourCharCode($1)})
    }
}
