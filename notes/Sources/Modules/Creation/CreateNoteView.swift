import SwiftUI

struct CreateNoteView: View {
  
  @ObservedObject var viewModel: CreateNoteViewModel
  
  var body: some View {
    Text("Create Note")
  }
}

struct CreateNoteScreen_Previews: PreviewProvider {
  static var previews: some View {
    CreateNoteView(viewModel: CreateNoteViewModel(api: NotesAPI()))
  }
}
