import SwiftUI

protocol FactoryProtocol {
  
  func makeRootView() -> AnyView
  func makeSignInView() -> AnyView
  func makeSignUpView() -> AnyView
  func makeNotesListView() -> AnyView
  func makeNotesCreationView() -> AnyView
}
