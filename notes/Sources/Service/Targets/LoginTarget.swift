import Moya

enum LoginTarget {
  case signUp(name: String?, email: String, password: String)
  case signIn(email: String, password: String)
}

extension LoginTarget: TargetType {
  
  var path: String {
    switch self {
    case .signUp:
      return "signup"
    case .signIn:
      return "signin"
    }
  }
  
  var baseURL: URL { URL(string: "https://notes-1ed6c.web.app/api/users")! }
  
  var method: Method { .post }
  
  var sampleData: Data { .init() }
  
  var task: Task {
    switch self {
    case let .signUp(name, email, password):
      return .requestParameters(
        parameters: [
          "name": name ?? "",
          "email": email,
          "password": password
        ],
        encoding: JSONEncoding.default
      )
      
    case let .signIn(email, password):
      return .requestParameters(
        parameters: [
          "email": email,
          "password": password
        ],
        encoding: JSONEncoding.default
      )
    }
  }
  
  var headers: [String : String]? { ["Content-Type": "application/json;charset=utf-8"] }
}
