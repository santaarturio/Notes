import Moya

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
  
  func fetchNotes(
    _ completion: @escaping (Result<[NoteDTO], Error>
    ) -> Void) {
    provider
      .request(.notes, callbackQueue: callbackQueue) {
        completion(handleResult($0))
      }
  }
  
  func createNote(
    title: String?,
    text: String?,
    completion: @escaping (Result<NoteDTO, Error>) -> Void
  ) {
    provider
      .request(.create(title: title ?? "", text: text ?? ""), callbackQueue: callbackQueue) {
        completion(handleResult($0))
      }
  }
}
