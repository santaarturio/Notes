import Moya
import Combine
import Result

final class LoginAPI: BaseAPI<LoginTarget>, LoginAPIProtocol {
  
  func signUp(
    name: String?,
    email: String,
    password: String
  ) -> AnyPublisher<API.User, Error> {
    requestPublisher(.signUp(name: name, email: email, password: password))
  }
  
  func signIn(
    email: String,
    password: String
  ) -> AnyPublisher<API.User, Error> {
    requestPublisher(.signIn(email: email, password: password))
  }
  
  func refreshToken() -> AnyPublisher<Void, Error> {
    provider
      .requestPublisher(.signIn(
        email: KeyHolder.default.get(.email) ?? "",
        password: KeyHolder.default.get(.password) ?? ""
      ), callbackQueue: callbackQueue)
      .map(API.User.self)
      .map { KeyHolder.default.update($0.jwt ?? "", for: .token) }
      .mapError(AnyError.init)
      .eraseToAnyPublisher()
  }
}
