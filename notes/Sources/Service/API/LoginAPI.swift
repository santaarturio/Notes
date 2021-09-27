import Moya
import Combine

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
}
