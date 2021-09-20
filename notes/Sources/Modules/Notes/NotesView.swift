import SwiftUI

struct NotesView: View {
  
  @ObservedObject var viewModel: NotesViewModel
  
  var body: some View {
    NavigationView {
      VStack {
        Text("There will be notes, someday...")
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarTitle(L10n.App.General.name)
      .navigationBarItems(leading: Button(action: viewModel.logout) {
        Text(L10n.App.Login.logOut)
      })
    }
  }
}

struct NotesScreen_Previews: PreviewProvider {
  static var previews: some View {
    NotesView(viewModel: NotesViewModel(api: NotesAPI()))
  }
}
