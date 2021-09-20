import SwiftUI

protocol FactoryProtocol {
  
  func makeRootView() -> AnyView
  func makeLoginView() -> AnyView
  func makeSignUpView() -> AnyView
  func makeNotesView() -> AnyView
  func makeCreateNoteView() -> AnyView
}
