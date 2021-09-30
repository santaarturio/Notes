import SwiftUI
import Combine

final class NotesCreationViewModel: ObservableObject {
  
  var cancellables: Set<AnyCancellable> = []
  
  private let notesDataBase: NotesDataBaseProtocol
  
  @Published var title = ""
  @Published var body = ""
  @Published var done: (() -> Void)?
  @Published var saved = false
  
  init(notesDataBase: NotesDataBaseProtocol) {
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
    notesDataBase
      .create(title: title, text: body)
    saved = true
  }
}
