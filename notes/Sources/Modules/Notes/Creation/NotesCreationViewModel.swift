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
    
    $title.merge(with: $body)
      .map { text in
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          ? weakify(NotesCreationViewModel.createNote, object: self)
          : nil
      }
      .assign(to: &$done)
  }
}

private extension NotesCreationViewModel {
  
  func createNote() {
    func save(note: Note) {
      let entity = NoteMO(context: CoreDataManager.instance.backgroundContext)
      
      entity.id = note.id.string
      entity.title = note.title
      entity.text = note.text
      
      CoreDataManager.instance.saveBackgroundContext()
    }
    
    api
      .createNote(title: title, text: body)
      .sink(
        receiveCompletion: { [weak self] completion in
          switch completion {
          case .finished:
            self?.saved = true
          case let .failure(error):
            print("Error occured while creating new note: \(error.localizedDescription)")
          }
        },
        receiveValue: { save(note: Note(dto: $0)) }
      )
      .store(in: &cancellables)
  }
}
