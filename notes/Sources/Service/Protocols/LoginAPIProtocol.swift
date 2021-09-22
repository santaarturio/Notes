import Combine

protocol LoginAPIProtocol {
  
  func signUp(name: String?, email: String, password: String) -> Future<UserDTO, Error>
  func signIn(email: String, password: String) -> Future<UserDTO, Error>
}
