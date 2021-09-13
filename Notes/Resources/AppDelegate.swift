import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    
    refreshToken()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    Router.shared.setRootViewController(window)
    window?.makeKeyAndVisible()
    
    return true
  }
}

private extension AppDelegate {
  
  private func refreshToken() {
    if KeyHolder.isUserLoggedIn() {
      LoginAPI()
        .signIn(
          email: KeyHolder.get(.email) ?? "",
          password: KeyHolder.get(.password) ?? ""
        ) { result in
          
          switch result {
          case let .success(userDTO):
            KeyHolder.update(userDTO.jwt ?? "", for: .token)
            
            #if DEBUG
            print(">>> Token has been refreshed 🦞 <<<")
            #endif
            
          case let .failure(error):
            #if DEBUG
            print(">>> Error occurred while refreshing token 🧨 <<<")
            print("ERROR: ", error.localizedDescription)
            #endif
          }
        }
    }
  }
}
