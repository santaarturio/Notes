import Combine

protocol LoginAPIProtocol {
  
  func signUp(name: String?, email: String, password: String) -> AnyPublisher<UserDTO, Error>
  func signIn(email: String, password: String) -> AnyPublisher<UserDTO, Error>
}
