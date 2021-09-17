import SwiftUI

struct CreateNoteScreen: View {
  
  @ObservedObject var viewModel: CreateNoteViewModel
  
  var body: some View {
    Text("Create Note")
  }
}

struct CreateNoteScreen_Previews: PreviewProvider {
  static var previews: some View {
    CreateNoteScreen(viewModel: CreateNoteViewModel(api: NotesAPI()))
  }
}
