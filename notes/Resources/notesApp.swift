import SwiftUI

@main
struct notesApp: App {
  
  var body: some Scene {
    WindowGroup { Factory().makeRootScreen() }
  }
}
