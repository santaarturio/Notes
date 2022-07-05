import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift

final class LoginAPI: LoginAPIProtocol {
  
  func signUp(
    name: String?,
    email: String,
    password: String
  ) -> AnyPublisher<API.User, Error> {
    Auth.auth()
      .createUser(withEmail: email, password: password)
      .map(\.user)
      .map(API.User.init)
      .eraseToAnyPublisher()
  }
  
  func signIn(
    email: String,
    password: String
  ) -> AnyPublisher<API.User, Error> {
    Auth.auth()
      .signIn(withEmail: email, password: password)
      .map(\.user)
      .map(API.User.init)
      .eraseToAnyPublisher()
  }
  
  func logout() {
    do { try Auth.auth().signOut() } catch { }
  }
}

private extension API.User {
  
  init(user: User) {
    jwt = user.refreshToken
    id = user.uid
    name = user.displayName ?? ""
    email = user.email ?? ""
  }
}
