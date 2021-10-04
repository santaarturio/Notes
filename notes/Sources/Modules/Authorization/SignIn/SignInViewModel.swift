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
  func receiveCompletion(_ completion: Subscribers.Completion<Error>) {
    isDownloading = false
  }
  
  func receiveValue(_ dto: API.User) {
    KeyHolder.default.update(email, for: .email)
    KeyHolder.default.update(password, for: .password)
    KeyHolder.default.update(dto.jwt ?? "", for: .token)
  }
  
  private func handleSignIn() {
    isDownloading = true
    
    api
      .signIn(
        email: email,
        password: password
      )
      .sink(
        receiveCompletion: weakify(SignInViewModel.receiveCompletion, object: self),
        receiveValue: weakify(SignInViewModel.receiveValue, object: self)
      )
      .store(in: &cancellables)
  }
}
