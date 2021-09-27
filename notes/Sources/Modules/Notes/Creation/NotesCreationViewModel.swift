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
  
  func save(note: API.Note, isSync: Bool) {
    let manager = CoreDataManager.instance
    
    manager
      .backgroundContext
      .perform {
        let entity = Note(context: manager.backgroundContext)
        entity.configure(note: note, isSync: isSync)
      }
    
    manager.saveBackgroundContext()
  }
  
  func createNote() {
    
    api
      .createNote(title: title, text: body)
      .sink(
        receiveCompletion: { [weak self] completion in
          defer { self?.saved = true }
          
          switch completion {
          case .finished:
            break
            
          case let .failure(error):
            print("Error occured while creating new note: \(error.localizedDescription)")
            print("Saving offline")
            
            self?
              .save(
                note: API.Note(
                  id: Date().description,
                  title: self?.title ?? "",
                  subtitle: self?.body ?? "",
                  date: Date().description
                ),
                isSync: false
              )
          }
        },
        receiveValue: { [weak self] dto in self?.save(note: dto, isSync: true) }
      )
      .store(in: &cancellables)
  }
}
