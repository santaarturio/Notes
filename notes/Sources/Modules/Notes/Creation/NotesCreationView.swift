import SwiftUI

struct NotesCreationView: View {
  
  @Environment(\.presentationMode) var presentation
  @ObservedObject var viewModel: NotesCreationViewModel
  
  var body: some View {
    VStack {
      TitleTextEditor(
        text: $viewModel.title,
        isPlaceholderShown: $viewModel.title.map { $0.isEmpty }
      )
      
      Spacer(minLength: 16)
      
      BodyTextEditor(
        text: $viewModel.body,
        isPlaceholderShown: $viewModel.body.map { $0.isEmpty }
      )
    }
    .padding()
    .gesture(DragGesture().onChanged { _ in endEditing() })
    .navigationBarItems(
      trailing: Button(action: { viewModel.done?() }) {
        Text(L10n.App.Creation.done)
      }.disabled(viewModel.done == nil)
    ).onAppear {
      viewModel
        .$saved
        .sink { saved in if saved { presentation.wrappedValue.dismiss() } }
        .store(in: &viewModel.cancellables)
    }.onDisappear {
      viewModel
        .cancellables
        .removeAll()
    }
  }
}

// MARK: - Subviews
private extension NotesCreationView {
  
  // MARK: TitleTextEditor
  struct TitleTextEditor: View {
    @Binding var text: String
    @Binding var isPlaceholderShown: Bool
    
    var body: some View {
      TextEditor(text: $text)
        .font(.title)
        .frame(height: 88)
        .overlay(
          Text(L10n.App.Creation.Placeholder.title)
            .font(.title)
            .foregroundColor(.gray)
            .opacity(isPlaceholderShown ? 1 : 0)
            .offset(x: 6, y: 8),
          alignment: .topLeading
        )
    }
  }
  
  // MARK: BodyTextEditor
  struct BodyTextEditor: View {
    @Binding var text: String
    @Binding var isPlaceholderShown: Bool
    
    var body: some View {
      TextEditor(text: $text)
        .font(.title3)
        .overlay(
          Text(L10n.App.Creation.Placeholder.body)
            .font(.title3)
            .foregroundColor(.gray)
            .opacity(isPlaceholderShown ? 1 : 0)
            .offset(x: 4, y: 8),
          alignment: .topLeading
        )
    }
  }
}

// MARK: - PreviewProvider
struct CreateNoteScreen_Previews: PreviewProvider {
  static var previews: some View {
    NotesCreationView(viewModel: NotesCreationViewModel(notesDataBase: NotesDataBase.shared))
  }
}
