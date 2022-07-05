import Combine

protocol LoginAPIProtocol {
  
  func signUp(name: String?, email: String, password: String) -> AnyPublisher<API.User, Error>
  func signIn(email: String, password: String) -> AnyPublisher<API.User, Error>
  func logout()
}
