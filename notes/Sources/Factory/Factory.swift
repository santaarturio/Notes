import SwiftUI

struct Factory: FactoryProtocol {
  
  func makeRootView() -> AnyView {
    AnyView(RootView(login: makeLoginView, notes: makeNotesView))
  }
  
  func makeLoginView() -> AnyView {
    AnyView(LoginView(viewModel: LoginViewModel(api: LoginAPI())))
  }
  
  func makeSignUpView() -> AnyView {
    AnyView(SignUpView(viewModel: SignUpViewModel(api: LoginAPI())))
  }
  
  func makeNotesView() -> AnyView {
    AnyView(NotesView(viewModel: NotesViewModel(api: NotesAPI())))
  }
  
  func makeCreateNoteView() -> AnyView {
    AnyView(CreateNoteView(viewModel: CreateNoteViewModel(api: NotesAPI())))
  }
}
