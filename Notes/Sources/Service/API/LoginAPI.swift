import Moya

class LoginAPI: LoginAPIProtocol {
  
  let provider: MoyaProvider<LoginTarget>
  let callbackQueue: DispatchQueue
  
  init(
    provider: MoyaProvider<LoginTarget> = .init(),
    callbackQueue: DispatchQueue = .main
  ) {
    self.provider = provider
    self.callbackQueue = callbackQueue
  }
  
  func signUp(
    name: String?,
    email: String,
    password: String,
    completion: @escaping (Result<UserDTO, Error>) -> Void
  ) {
    provider
      .request(.signUp(name: name, email: email, password: password), callbackQueue: callbackQueue) {
        completion(handleResult($0))
      }
  }
  
  func signIn(
    email: String,
    password: String,
    completion: @escaping (Result<UserDTO, Error>) -> Void
  ) {
    provider
      .request(.signIn(email: email, password: password), callbackQueue: callbackQueue) {
        completion(handleResult($0))
      }
  }
}
