import UIKit

final class Router {
  
  static let shared = Router()
  
  private let factory: FactoryProtocol = Factory()
  private var navigationController = UINavigationController()
  
  enum Destination {
    case notes
  }
  
  func setRootViewController(_ window: UIWindow?) {
    navigationController = UINavigationController(
      rootViewController: KeyHolder.isUserLoggedIn()
        ? factory.makeNotesVC()
        : factory.makeLoginVC()
    )
    window?.rootViewController = navigationController
  }
  
  func navigate(to destination: Destination) {
    switch destination {
    case .notes:
      navigationController
        .pushViewController(factory.makeNotesVC(), animated: true)
    }
  }
}
