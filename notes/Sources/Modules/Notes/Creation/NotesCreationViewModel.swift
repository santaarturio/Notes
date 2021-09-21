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
      defer { saved = true }
      
      let entity = NoteMO(context: CoreDataManager.instance.viewContext)
      entity.id = note.id.string
      entity.title = note.title
      entity.text = note.text
      
      CoreDataManager.instance.saveContext()
    }
    
    api
      .createNote(title: title, text: body) { result in
        switch result {
        case let .success(dto):
          save(note: Note(dto: dto))
          
        case let .failure(error):
          print(error.localizedDescription)
        }
      }
  }
}
