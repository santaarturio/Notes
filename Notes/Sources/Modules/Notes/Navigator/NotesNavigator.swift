import UIKit

final class NotesNavigator: Mixin<UINavigationController?>, NavigatorProtocol {
  
  private let factory: FactoryProtocol = Factory.shared
  
  enum Destination { case login }
  
  func navigate(to destination: Destination) {
    switch destination {
    case .login:
      let loginVC = factory.makeLoginVC()
      loginVC.modalPresentationStyle = .fullScreen
      
      base?
        .present(
          loginVC,
          animated: true,
          completion: nil
        )
    }
  }
}
