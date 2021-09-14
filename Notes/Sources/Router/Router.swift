import UIKit

final class Router {
  
  static let shared = Router()
  
  private let factory: FactoryProtocol = Factory()
  private var navigationController = UINavigationController()
  
  enum Destination {
    case notes, login
  }
  
  func setRootViewController(_ window: UIWindow?) {
    navigationController = UINavigationController(
      rootViewController: factory.makeNotesVC()
    )
    window?.rootViewController = navigationController
  }
  
  func navigate(to destination: Destination) {
    switch destination {
    case .login:
      let loginVC = factory.makeLoginVC()
      loginVC.modalPresentationStyle = .fullScreen
      navigationController
        .present(loginVC, animated: true, completion: nil)
      
    case .notes:
      navigationController
        .dismiss(animated: true, completion: nil)
    }
  }
}
