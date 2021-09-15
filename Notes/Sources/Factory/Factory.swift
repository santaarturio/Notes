import UIKit

final class Factory: FactoryProtocol {
  
  static let shared = Factory()
  
  private let navigationController: UINavigationController = .init()
  
  func makeLoginVC() -> UIViewController {
    let vc = LoginVC()
    let viewModel = LoginViewModel(api: .init(), navigator: .init(base: navigationController))
    vc.bind(viewModel)
    return vc
  }
  
  func makeNotesVC() -> UIViewController {
    let vc = NotesTableVC()
    let viewModel = NotesViewModel(api: .init(), navigator: .init(base: navigationController))
    vc.bind(viewModel)
    navigationController.viewControllers = [vc]
    return navigationController
  }
}
