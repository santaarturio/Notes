import SwiftUI

struct NotesListView: View {
  
  @ObservedObject var viewModel: NotesListViewModel
  
  var body: some View {
    NavigationView {
      List(viewModel.notes) { NotePreviewCell(note: $0) }
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(leading: leadingNavigationItem, trailing: trailingNavigationItem)
      .navigationBarTitle(L10n.App.General.name)
      .animation(.easeInOut)
    }
    .accentColor(Color(Asset.Colors.stillYellow.color))
  }
}

// MARK: - Subviews
private extension NotesListView {
  
  // MARK: NotePreviewCell
  struct NotePreviewCell: View {
    let note: Note
    
    var body: some View {
      VStack(alignment: .leading) {
        Text(note.title ?? L10n.App.List.Empty.title)
          .font(.title3)
          .fontWeight(.medium)
          .lineLimit(1)
        Text(note.text ?? L10n.App.List.Empty.body)
          .font(.body)
          .lineLimit(1)
      }
    }
  }
  
  // MARK: leadingNavigationItem
  private var leadingNavigationItem: some View {
    Button(action: viewModel.logout) {
      Text(L10n.App.Login.logOut)
    }
  }
  
  // MARK: trailingNavigationItem
  private var trailingNavigationItem: some View {
    NavigationLink(
      destination: LinkPresenter { viewModel.creationView }
    ) {
      Image(uiImage: Asset.Images.createNote.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 24)
    }
  }
}

// MARK: - PreviewProvider
struct NotesScreen_Previews: PreviewProvider {
  static var previews: some View {
    NotesListView(viewModel: NotesListViewModel(loginAPI: LoginAPI(), notesAPI: NotesAPI()))
  }
}
