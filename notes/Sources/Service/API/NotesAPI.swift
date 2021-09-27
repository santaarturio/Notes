import Moya
import Combine
import struct Result.AnyError

final class NotesAPI: BaseAPI<NotesTarget> {
  
  override init(
    provider: MoyaProvider<NotesTarget> = .init(
      plugins: [
        AccessTokenPlugin(tokenClosure: { _ in KeyHolder.default.get(.token) ?? "" })
      ]
    ),
    callbackQueue: DispatchQueue = .main
  ) {
    super.init(provider: provider, callbackQueue: callbackQueue)
  }
}

extension NotesAPI: NotesAPIProtocol {
  
  func fetchNotes() -> AnyPublisher<[NoteDTO], Error> {
    requestPublisher(.notes)
  }
  
  func createNote(
    title: String,
    text: String
  ) -> AnyPublisher<NoteDTO, Error> {
    requestPublisher(.create(title: title, text: text))
  }
}
