import Moya
import Combine

final class NotesAPI: BaseAPI<NotesTarget> {
  
  override init(
    provider: MoyaProvider<NotesTarget> = .init(
      plugins: [
        AccessTokenPlugin(tokenClosure: { _ in KeyHolder.default.get(.token) ?? "" }),
        Plugin401(onStatusCode401: { KeyHolder.default.flush() })
      ]
    ),
    callbackQueue: DispatchQueue = .main
  ) {
    super.init(provider: provider, callbackQueue: callbackQueue)
  }
}

extension NotesAPI: NotesAPIProtocol {
  
  func fetchNotes() -> AnyPublisher<[API.Note], Error> {
    requestPublisher(.notes)
  }
  
  func createNote(
    title: String,
    text: String
  ) -> AnyPublisher<API.Note, Error> {
    requestPublisher(.create(title: title, text: text))
  }
}
