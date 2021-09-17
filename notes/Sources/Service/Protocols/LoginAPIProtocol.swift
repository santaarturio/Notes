
protocol LoginAPIProtocol {
  
  func signUp(name: String?, email: String, password: String, completion: @escaping (Result<UserDTO, Error>) -> Void)
  func signIn(email: String, password: String, completion: @escaping (Result<UserDTO, Error>) -> Void)
}
