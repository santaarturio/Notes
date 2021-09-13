import Combine

final class LoginViewModel {
  
  private let api = LoginAPI()
  
  private var cancellables: Set<AnyCancellable> = []
  
  // MARK: - Input
  let backSubject = PassthroughSubject<Void, Never>()
  let goSubject = PassthroughSubject<Void, Never>()
  
  let nameSubject = CurrentValueSubject<String, Never>("")
  let emailSubject = CurrentValueSubject<String, Never>("")
  let passwordSubject = CurrentValueSubject<String, Never>("")
  
  let signUpSubject = PassthroughSubject<Void, Never>()
  let signInSubject = PassthroughSubject<Void, Never>()
  
  // MARK: - Output
  let stateSubject = PassthroughSubject<State, Never>(); enum State {
    case initial, signUp, signIn, go(Bool)
  }
  
  init() { bindData() }
}

// MARK: - Bind Data
extension LoginViewModel {
  
  func bindData() {
    backSubject
      .map { .initial }
      .subscribe(stateSubject)
      .store(in: &cancellables)
    
    signUpSubject
      .map { .signUp }
      .subscribe(stateSubject)
      .store(in: &cancellables)
    
    signInSubject
      .map { .signIn }
      .subscribe(stateSubject)
      .store(in: &cancellables)
    
    emailSubject
      .combineLatest(passwordSubject)
      .dropFirst()
      .map { .go($0.count > 9 && $1.count > 7) }
      .subscribe(stateSubject)
      .store(in: &cancellables)
    
    let signUp = signUpSubject
      .zip(goSubject)
      .map { _ in Endpoint.signUp }
    
    let signIn = signInSubject
      .zip(goSubject)
      .map { _ in Endpoint.signIn }
    
    signUp.merge(with: signIn)
      .sink(receiveValue: weakify(LoginViewModel.handleLogin, object: self))
      .store(in: &cancellables)
  }
  
  // MARK: - Handle Login
  private enum Endpoint { case signUp, signIn }
  private func handleLogin(_ endpoint: Endpoint) {
    
    func handleResult(_ result: Result<UserDTO, Error>) {
      switch result {
      case let .success(userDTO):
        KeyHolder.update(emailSubject.value, for: .email)
        KeyHolder.update(passwordSubject.value, for: .password)
        KeyHolder.update(userDTO.jwt ?? "", for: .token)
        Router.shared.navigate(to: .notes)
        
      case let .failure(error):
        print(error.localizedDescription)
      }
    }
    
    switch endpoint {
    case .signUp:
      api
        .signUp(
          name: nameSubject.value,
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
