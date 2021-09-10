import Moya

class NotesAPI: NotesAPIProtocol {
  
  let provider: MoyaProvider<NotesTarget>
  let callbackQueue: DispatchQueue
  
  init(
    provider: MoyaProvider<NotesTarget> = .init(
      plugins: [
        AccessTokenPlugin(tokenClosure: { _ in KeyHolder.get(.token) ?? "" })
      ]
    ),
    callbackQueue: DispatchQueue = .main
  ) {
    self.provider = provider
    self.callbackQueue = callbackQueue
  }
  
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
