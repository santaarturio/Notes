import Moya

class BaseAPI<T: TargetType> {
  
  let provider: MoyaProvider<T>
  let callbackQueue: DispatchQueue
  
  init(
    provider: MoyaProvider<T> = .init(),
    callbackQueue: DispatchQueue = .main
  ) {
    self.provider = provider
    self.callbackQueue = callbackQueue
  }
}

func handleResult<T: Decodable>(_ result: Result<Response, MoyaError>) -> Result<T, Error> {
  do {
    return .success(try JSONDecoder().decode(T.self, from: result.get().data))
  } catch {
    return .failure(error)
  }
}
