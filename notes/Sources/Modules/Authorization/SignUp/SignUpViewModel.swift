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
  func receiveCompletion(_ completion: Subscribers.Completion<Error>) {
    isDownloading = false
  }
  
  func receiveValue(_ dto: API.User) {
    KeyHolder.default.update(dto.id, for: .userId)
    KeyHolder.default.update(dto.jwt ?? "", for: .token)
  }
  
  private func handleSignUp() {
    isDownloading = true
    
    api
      .signUp(
        name: name,
        email: email,
        password: password
      )
      .sink(
        receiveCompletion: weakify(SignUpViewModel.receiveCompletion, object: self),
        receiveValue: weakify(SignUpViewModel.receiveValue, object: self)
      )
      .store(in: &cancellables)
  }
}
