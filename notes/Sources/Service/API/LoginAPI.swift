import Moya
import Combine

final class LoginAPI: BaseAPI<LoginTarget>, LoginAPIProtocol {
  
  func signUp(
    name: String?,
    email: String,
    password: String
  ) -> Future<UserDTO, Error> {
    future(.signUp(name: name, email: email, password: password))
  }
  
  func signIn(
    email: String,
    password: String
  ) -> Future<UserDTO, Error> {
    future(.signIn(email: email, password: password))
  }
}
