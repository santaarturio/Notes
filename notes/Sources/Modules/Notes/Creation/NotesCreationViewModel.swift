import SwiftUI
import Combine
import CoreData

final class NotesCreationViewModel: ObservableObject {
  
  var cancellables: Set<AnyCancellable> = []
  private let notesAPI: NotesAPIProtocol
  private let dataBaseManager: NotesDataBaseProtocol
  
  @Published var title = ""
  @Published var body = ""
  @Published var done: (() -> Void)?
  @Published var saved = false
  
  init(
    notesAPI: NotesAPIProtocol,
    dataBaseManager: NotesDataBaseProtocol
  ) {
    self.notesAPI = notesAPI
    self.dataBaseManager = dataBaseManager
    
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
        receiveCompletion: { [weak self] completion in
          
          defer {
            self?.dataBaseManager.save()
            self?.saved = true
          }
          
          guard case let .failure(error) = completion else { return }
          
          print("Error occured while creating new note: \(error.localizedDescription)")
          print("Saving offline")
          
          self?
            .dataBaseManager
            .create { mo in
              mo.id = Date().description
              mo.title = self?.title
              mo.text = self?.body
              mo.date = Date()
              mo.isSync = false
            }
        },
        receiveValue: { [weak dataBaseManager] note in
          dataBaseManager?
            .create { $0.configure(note: note) }
        }
      )
      .store(in: &cancellables)
  }
}
