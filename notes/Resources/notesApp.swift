import SwiftUI

@main
struct notesApp: App {
  @Environment(\.scenePhase) private var scenePhase
  
  var body: some Scene {
    WindowGroup { Factory().makeRootView() }
    
    .onChange(of: scenePhase) { phase in
      guard
        phase != .active else { return }
      
      DataBaseManager.notes.save()
    }
  }
}
