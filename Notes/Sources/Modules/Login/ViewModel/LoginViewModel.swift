import Combine

final class LoginViewModel {
  
  private let api: LoginAPI
  private let navigator: LoginNavigator
  
  private var cancellables: Set<AnyCancellable> = []
  
  // MARK: - Input
  let emailSubject = CurrentValueSubject<String, Never>("")
  let passwordSubject = CurrentValueSubject<String, Never>("")
  
  let signUpSubject = PassthroughSubject<Void, Never>()
  let signInSubject = PassthroughSubject<Void, Never>()
  
  // MARK: - Output
  let canGoSubject = PassthroughSubject<Bool, Never>()
  let isDownloadingSubject = PassthroughSubject<Bool, Never>()
  
  init(
    api: LoginAPI,
    navigator: LoginNavigator)
  {
    self.api = api
    self.navigator = navigator
    
    bindData()
  }
}

// MARK: - Bind Data
extension LoginViewModel {
  
  func bindData() {
    emailSubject
      .combineLatest(passwordSubject)
      .map { $0.count > 9 && $1.count > 7 }
      .subscribe(canGoSubject)
      .store(in: &cancellables)
    
    let signUp = signUpSubject
      .map { _ in Endpoint.signUp }
    
    let signIn = signInSubject
      .map { _ in Endpoint.signIn }
    
    signUp.merge(with: signIn)
      .sink(receiveValue: weakify(LoginViewModel.handleLogin, object: self))
      .store(in: &cancellables)
  }
  
  // MARK: - Handle Login
  private enum Endpoint { case signUp, signIn }
  private func handleLogin(_ endpoint: Endpoint) {
    isDownloadingSubject.send(true)
    
    func handleResult(_ result: Result<UserDTO, Error>) {
      isDownloadingSubject.send(false)
      
      switch result {
      case let .success(userDTO):
        KeyHolder.update(emailSubject.value, for: .email)
        KeyHolder.update(passwordSubject.value, for: .password)
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
          email: emailSubject.value,
          password: passwordSubject.value,
          completion: handleResult(_:)
        )
      
    case .signIn:
      api
        .signIn(
          email: emailSubject.value,
          password: passwordSubject.value,
          completion: handleResult(_:)
        )
    }
  }
}
