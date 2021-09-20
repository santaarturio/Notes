import SwiftUI
import Combine

final class SignUpViewModel: ObservableObject {
  
  private var cancellables: Set<AnyCancellable> = []
  private let api: LoginAPIProtocol
  
  @Published var name = ""
  @Published var email = ""
  @Published var password = ""
  @Published var signUp: (() -> Void)?
  @Published var isDownloading = false
  
  init(api: LoginAPIProtocol) {
    self.api = api
    
    $email
      .combineLatest($password)
      .map { $0.count > 9 && $1.count > 7 ? weakify(SignUpViewModel.handleSignUp, object: self) : nil }
      .assign(to: &$signUp)
  }
}

extension SignUpViewModel {
  
  // MARK: - Sign Up
  private func handleSignUp() {
    isDownloading = true
    
    func handleResult(_ result: Result<UserDTO, Error>) {
      isDownloading = false
      
      switch result {
      case let .success(userDTO):
        KeyHolder.default.update(email, for: .email)
        KeyHolder.default.update(password, for: .password)
        KeyHolder.default.update(userDTO.jwt ?? "", for: .token)
        
      case let .failure(error):
        print(error.localizedDescription)
      }
    }
    
    api
      .signUp(
        name: name,
        email: email,
        password: password,
        completion: handleResult(_:)
      )
  }
}
