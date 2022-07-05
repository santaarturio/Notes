import SwiftUI
import Combine

final class NotesListViewModel: ObservableObject {
  
  private var cancellables: Set<AnyCancellable> = []
  
  private let loginAPI: LoginAPIProtocol
  private let notesAPI: NotesAPIProtocol
  private let notesDataBase: NotesDataBaseProtocol
  
  @Published var notes: [Note] = []
  
  lazy var logout: () -> Void = { [weak self] in
    self?.loginAPI.logout()
    KeyHolder.default.flush()
  }
  
  init(
    loginAPI: LoginAPIProtocol,
    notesAPI: NotesAPIProtocol,
    notesDataBase: NotesDataBaseProtocol
  ) {
    self.loginAPI = loginAPI
    self.notesAPI = notesAPI
    self.notesDataBase = notesDataBase
    
    setupNetworking()
    
    notesDataBase
      .notesPublisher
      .assign(to: &$notes)
  }
}

private extension NotesListViewModel {
  
  func setupNetworking() {
    downloadNotes()
    uploadNotes()
  }
  
  func downloadNotes() {
    notesAPI
      .fetchNotes()
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { [weak self] dtos in
          dtos.forEach { dto in
            self?
              .notesDataBase
              .updateNote(id: dto.id) { note in
                note.configure(
                  dto: dto,
                  creatorId: KeyHolder.default.get(.userId)
                )
              }
          }
        }
      )
      .store(in: &cancellables)
  }
  
  func uploadNotes() {
    let api = notesAPI
    
    notesDataBase
      .allAnsynced { notes in
        notes.forEach { note in
          api
            .createNote(
              title: note.title ?? "",
              text: note.text ?? ""
            )
            .sink(
              receiveCompletion: { _ in },
              receiveValue: { dto in
                note.configure(
                  dto: dto,
                  creatorId: KeyHolder.default.get(.userId)
                )
              }
            )
            .store(in: &API.cancellables)
        }
      }
  }
}

private extension API {
  /// The cancellables used for sync untracked entities, it shouldn't be affected by ViewModel or other lifecycle
  static var cancellables: Set<AnyCancellable> = []
}
