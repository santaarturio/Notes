import SwiftUI
import Combine

final class SignInViewModel: ObservableObject {
  
  private var cancellables: Set<AnyCancellable> = []
  
  private let api: LoginAPIProtocol
  private let factory: FactoryProtocol = Factory()
  
  private(set) lazy var signUpView: AnyView = { [weak self] in
    AnyView(self?.factory.makeSignUpView())
  }()
  
  @Published var email = ""
  @Published var password = ""
  @Published var signIn: (() -> Void)?
  @Published var isDownloading = false
  
  init(api: LoginAPIProtocol) {
    self.api = api
    
    $email
      .combineLatest($password)
      .map { $0.count > 9 && $1.count > 7 ? weakify(SignInViewModel.handleSignIn, object: self) : nil }
      .assign(to: &$signIn)
  }
}

extension SignInViewModel {
  
  // MARK: - Sign In
  private func handleSignIn() {
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
      .signIn(
        email: email,
        password: password,
        completion: handleResult(_:)
      )
  }
}