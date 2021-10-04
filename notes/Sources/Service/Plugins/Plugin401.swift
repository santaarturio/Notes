import Moya

struct Plugin401: PluginType {
  
  let onStatusCode401: () -> Void
  
  func didReceive(
    _ result: Result<Moya.Response, MoyaError>,
    target: TargetType
  ) {
    guard
      case let .success(response) = result,
      response.statusCode == 401 else { return }
    onStatusCode401()
  }
}
