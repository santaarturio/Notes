import SwiftUI

struct LinkPresenter<Content: View>: View {
  let content: () -> Content
  @State private var invlidated = false
  
  var body: some View {
    Group {
      if self.invlidated {
        EmptyView()
      } else {
        content()
      }
    }
    .onDisappear { self.invlidated = true }
  }
  
  init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
  }
}
