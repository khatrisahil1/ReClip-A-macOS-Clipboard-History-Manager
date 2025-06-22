//
//  PreferencesView.swift
//  ReClip
//
//  Created by SAHIL KHATRI on 21/06/25.
//


// In PreferencesView.swift

import SwiftUI

struct PreferencesView: View {
    var body: some View {
        // We use a Form for a standard macOS settings look.
        Form {
            VStack(alignment: .leading, spacing: 20) {
                Text("ReClip Preferences")
                    .font(.largeTitle)
                    .padding(.bottom)

                Text("Settings for future features like a customizable hotkey, history limit, and more will appear here in v2.0.")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
        }
        .frame(width: 480, height: 320) // Give the settings window a nice default size.
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}