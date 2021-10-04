import SwiftUI

struct Factory {
  
  func makeRootView() -> some View {
    RootView(login: makeSignInView, notes: makeNotesListView)
  }
  
  func makeSignInView() -> some View {
    SignInView(viewModel: SignInViewModel(api: LoginAPI()), signUpView: makeSignUpView)
  }
  
  func makeSignUpView() -> some View {
    SignUpView(viewModel: SignUpViewModel(api: LoginAPI()))
  }
  
  func makeNotesListView() -> some View {
    NotesListView(
      viewModel: NotesListViewModel(
        notesAPI: NotesAPI(),
        notesDataBase: DataBase.notesDataBase
      ),
      createView: makeNotesCreationView
    )
  }
  
  func makeNotesCreationView() -> some View {
    NotesCreationView(
      viewModel: NotesCreationViewModel(
        notesAPI: NotesAPI(),
        notesDataBase: DataBase.notesDataBase
      )
    )
  }
}
