import SwiftUI

struct RootView<Login: View, Notes: View>: View {
  
  @ObservedObject var keyHolder: KeyHolder = .default
  
  let login: () -> Login
  let notes: () -> Notes
  
  var body: some View {
    keyHolder.isUserLoggedIn
      ? AnyView(notes())
      : AnyView(login())
  }
}
