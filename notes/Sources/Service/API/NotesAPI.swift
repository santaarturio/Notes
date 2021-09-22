import Moya
import Combine

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
  
  func fetchNotes() -> Future<[NoteDTO], Error> {
    future(.notes)
  }
  
  func createNote(
    title: String,
    text: String
  ) -> Future<NoteDTO, Error> {
    future(.create(title: title, text: text))
  }
}
