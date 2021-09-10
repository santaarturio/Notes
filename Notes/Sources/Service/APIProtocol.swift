import Moya

protocol APIProtocol {
  associatedtype Target: TargetType
  var provider: MoyaProvider<Target> { get }
}

func handleResult<T: Decodable>(_ result: Result<Response, MoyaError>) -> Result<T, Error> {
  do {
    return .success(try JSONDecoder().decode(T.self, from: result.get().data))
  } catch {
    return .failure(error)
  }
}
