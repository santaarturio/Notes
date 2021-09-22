import SwiftUI

struct Factory: FactoryProtocol {
  
  func makeRootView() -> AnyView {
    AnyView(RootView(login: makeSignInView, notes: makeNotesListView))
  }
  
  func makeSignInView() -> AnyView {
    AnyView(SignInView(viewModel: SignInViewModel(api: LoginAPI())))
  }
  
  func makeSignUpView() -> AnyView {
    AnyView(SignUpView(viewModel: SignUpViewModel(api: LoginAPI())))
  }
  
  func makeNotesListView() -> AnyView {
    AnyView(NotesListView(viewModel: NotesListViewModel(loginAPI: LoginAPI(), notesAPI: NotesAPI())))
  }
  
  func makeNotesCreationView() -> AnyView {
    AnyView(NotesCreationView(viewModel: NotesCreationViewModel(api: NotesAPI())))
  }
}
