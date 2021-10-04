import SwiftUI
import Combine

final class NotesListViewModel: ObservableObject {
  
  private var cancellables: Set<AnyCancellable> = []
  
  private let notesAPI: NotesAPIProtocol
  private let notesDataBase: NotesDataBaseProtocol
  
  @Published var notes: [Note] = []
  
  lazy var logout: () -> Void = { [weak self] in
    KeyHolder.default.flush()
    self?.notesDataBase.removeAllNotes()
  }
  
  init(
    notesAPI: NotesAPIProtocol,
    notesDataBase: NotesDataBaseProtocol
  ) {
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
              .updateNote(id: dto.id) { note in note.configure(dto: dto) }
          }
        }
      )
      .store(in: &cancellables)
  }
  
  func uploadNotes() {
    
  }
}
