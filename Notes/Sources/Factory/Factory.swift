import UIKit
import SwiftUI

final class Factory: FactoryProtocol {
  
  static let shared = Factory()
  
  private let navigationController: UINavigationController = .init()
  
  func makeLoginVC() -> UIViewController {
    let view = LoginScreen(viewModel: LoginViewModel(api: .init(), navigator: .init(base: navigationController)))
    return UIHostingController(rootView: view, ignoreSafeArea: true)
  }
  
  func makeNotesVC() -> UIViewController {
    let vc = NotesTableVC()
    let viewModel = NotesViewModel(api: .init(), navigator: .init(base: navigationController))
    vc.bind(viewModel)
    navigationController.viewControllers = [vc]
    return navigationController
  }
}
