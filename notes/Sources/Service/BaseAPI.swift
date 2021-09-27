import Moya
import Combine
import struct Result.AnyError

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
  
  func requestPublisher<Response: Codable>(_ target: T) -> AnyPublisher<Response, Error> {
    provider
      .requestPublisher(target, callbackQueue: callbackQueue)
      .map(Response.self)
      .mapError(AnyError.init)
      .eraseToAnyPublisher()
  }
}
