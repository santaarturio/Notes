import SwiftUI

protocol FactoryProtocol {
  
  func makeRootScreen() -> AnyView
  func makeLoginScreen() -> AnyView
  func makeSignUpScreen() -> AnyView
  func makeNotesScreen() -> AnyView
  func makeCreateNoteScreen() -> AnyView
}
