import Moya

final class LoginAPI: BaseAPI<LoginTarget>, LoginAPIProtocol {
  
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
