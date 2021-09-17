import Combine
import SwiftUI

final class LoginViewModel: ObservableObject {
  
  private let api: LoginAPI
  private let navigator: LoginNavigator
  
  private var cancellables: Set<AnyCancellable> = []
  
  @Published var email = ""
  @Published var password = ""
  @Published private(set) var login: ((Endpoint) -> Void)?
  @Published var isDownloading = false
  
  init(
    api: LoginAPI,
    navigator: LoginNavigator
  ) {
    self.api = api
    self.navigator = navigator
    
    $email
      .combineLatest($password)
      .map { $0.count > 9 && $1.count > 7 ? weakify(LoginViewModel.handleLogin, object: self) : nil }
      .assign(to: &$login)
  }
}

extension LoginViewModel {
  
  // MARK: - Handle Login
  enum Endpoint { case signUp, signIn }
  private func handleLogin(_ endpoint: Endpoint) {
    isDownloading = true
    
    func handleResult(_ result: Result<UserDTO, Error>) {
      isDownloading = false
      
      switch result {
      case let .success(userDTO):
        KeyHolder.update(email, for: .email)
        KeyHolder.update(password, for: .password)
        KeyHolder.update(userDTO.jwt ?? "", for: .token)
        
        navigator.navigate(to: .dismiss)
        
      case let .failure(error):
        print(error.localizedDescription)
      }
    }
    
    switch endpoint {
    case .signUp:
      api
        .signUp(
          name: "",
          email: email,
          password: password,
          completion: handleResult(_:)
        )
      
    case .signIn:
      api
        .signIn(
          email: email,
          password: password,
          completion: handleResult(_:)
        )
    }
  }
}
