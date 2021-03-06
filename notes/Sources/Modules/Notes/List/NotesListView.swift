import SwiftUI

struct NotesListView<CreateView: View, DetailsView: View>: View {
  
  @ObservedObject var viewModel: NotesListViewModel
  
  let createView: () -> CreateView
  let detailsView: (Note) -> DetailsView
  
  var body: some View {
    NavigationView {
      List(viewModel.notes) { note in
        NavigationLink(destination: detailsView(note)) {
          NotePreviewCell(note: note)
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          leadingNavigationItem
        }
        ToolbarItem(placement: .principal) {
          Text(L10n.App.General.name)
            .fontWeight(.medium)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          trailingNavigationItem
        }
      }
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
      destination: LinkPresenter(createView)
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
    NotesListView(
      viewModel: NotesListViewModel(
        loginAPI: LoginAPI(),
        notesAPI: NotesAPI(),
        notesDataBase: DataBase.notes),
      createView: EmptyView.init,
      detailsView: { _ in EmptyView() }
    )
  }
}
