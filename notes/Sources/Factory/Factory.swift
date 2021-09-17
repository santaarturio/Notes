import SwiftUI

struct Factory: FactoryProtocol {
  
  func makeRootScreen() -> AnyView {
    AnyView(RootView(login: makeLoginScreen, notes: makeNotesScreen))
  }
  
  func makeLoginScreen() -> AnyView {
    AnyView(LoginScreen(viewModel: LoginViewModel(api: LoginAPI())))
  }
  
  func makeSignUpScreen() -> AnyView {
    AnyView(SignUpScreen(viewModel: SignUpViewModel(api: LoginAPI())))
  }
  
  func makeNotesScreen() -> AnyView {
    AnyView(NotesScreen(viewModel: NotesViewModel(api: NotesAPI())))
  }
  
  func makeCreateNoteScreen() -> AnyView {
    AnyView(CreateNoteScreen(viewModel: CreateNoteViewModel(api: NotesAPI())))
  }
}
