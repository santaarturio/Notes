import UIKit

final class LoginNavigator: Mixin<UINavigationController?>, NavigatorProtocol {
  
  enum Destination { case dismiss }
  
  func navigate(to destination: Destination) {
    switch destination {
    case .dismiss:
      base?
        .dismiss(
          animated: true,
          completion: nil
        )
    }
  }
}
