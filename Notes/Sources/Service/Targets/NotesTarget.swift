import Moya

enum NotesTarget {
  case notes
  case create(title: String, text: String)
}

extension NotesTarget: TargetType, AccessTokenAuthorizable {
  
  var authorizationType: AuthorizationType? { .bearer }
  
  var path: String { "notes" }
  
  var baseURL: URL { URL(string: "https://notes-1ed6c.web.app/api")! }
  
  var method: Method {
    switch self {
    case .notes:
      return .get
    case .create:
      return .put
    }
  }
  
  var sampleData: Data { .init() }
  
  var task: Task {
    switch self {
    case .notes:
      return .requestPlain
      
    case let .create(title, text):
      return .requestParameters(
        parameters: [
          "title": title,
          "subtitle": text
        ],
        encoding: JSONEncoding.default
      )
    }
  }
  
  var headers: [String : String]? { ["Content-Type": "application/json;charset=utf-8"] }
}
