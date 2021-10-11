import SwiftUI
import Combine

final class NotesCreationViewModel: ObservableObject {
  
  var cancellables: Set<AnyCancellable> = []
  
  private let notesAPI: NotesAPIProtocol
  private let notesDataBase: NotesDataBaseProtocol
  
  @Published var title = ""
  @Published var body = ""
  @Published var done: (() -> Void)?
  @Published var saved = false
  
  init(
    notesAPI: NotesAPIProtocol,
    notesDataBase: NotesDataBaseProtocol
  ) {
    self.notesAPI = notesAPI
    self.notesDataBase = notesDataBase
    
    $title.combineLatest($body)
      .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !$1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .sink { [weak self] isFulFilled in self?.done = isFulFilled ? { self?.createNote() } : nil }
      .store(in: &cancellables)
  }
}

private extension NotesCreationViewModel {
  
  func createNote() {
    notesAPI
      .createNote(title: title, text: body)
      .sink(
        receiveCompletion: weakify(NotesCreationViewModel.saveNoteOfflineIfNeeded, object: self),
        receiveValue: { [weak self] dto in
          self?
            .notesDataBase
            .createNote { note in
              note.configure(
                dto: dto,
                creatorId: KeyHolder.default.get(.userId)
              )
            }
        }
      )
      .store(in: &cancellables)
  }
  
  func saveNoteOfflineIfNeeded(_ completion: Subscribers.Completion<Error>) {
    saved = true
    
    guard
      case .failure = completion else { return }
    
    notesDataBase
      .createNote { [weak self] note in
        note.configure(
          title: self?.title,
          text: self?.body,
          creatorId: KeyHolder.default.get(.userId)
        )
      }
  }
}
