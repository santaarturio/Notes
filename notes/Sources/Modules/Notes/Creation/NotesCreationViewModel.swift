import SwiftUI
import Combine
import CoreData

final class NotesCreationViewModel: ObservableObject {
  
  var cancellables: Set<AnyCancellable> = []
  private let api: NotesAPIProtocol
  
  @Published var title = ""
  @Published var body = ""
  @Published var done: (() -> Void)?
  @Published var saved = false
  
  init(api: NotesAPIProtocol) {
    self.api = api
    
    $title.combineLatest($body)
      .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !$1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .sink { [weak self] isFulFilled in self?.done = isFulFilled ? { self?.createNote() } : nil }
      .store(in: &cancellables)
  }
}

private extension NotesCreationViewModel {
  
  func save(note: Note) {
    let manager = CoreDataManager.instance
    
    manager
      .backgroundContext
      .perform {
        let entity = NoteMO(context: manager.backgroundContext)
        entity.id = note.id.string
        entity.title = note.title
        entity.text = note.text
        entity.date = note.date ?? Date()
      }
    
    manager.saveBackgroundContext()
  }
  
  func createNote() {
    
    api
      .createNote(title: title, text: body)
      .sink(
        receiveCompletion: { [weak self] completion in
          switch completion {
          case .finished:
            self?.saved = true
          case let .failure(error):
            print("Error occured while creating new note: \(error.localizedDescription)")
            print("Saving offline")
            // TODO: offline mode
          }
        },
        receiveValue: { weakify(NotesCreationViewModel.save, object: self)(Note(dto: $0)) }
      )
      .store(in: &cancellables)
  }
}
