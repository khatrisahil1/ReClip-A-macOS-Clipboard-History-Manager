import SwiftUI

@main
struct ReClipApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  // It's impossible to create a sceneless application,
  // so we are hacking this around by creating a menubar
  // scene that is always hidden.
  @State private var hiddenMenu: Bool = false

  var body: some Scene {
    MenuBarExtra("", isInserted: $hiddenMenu) {
      EmptyView()
    }
  }
}
