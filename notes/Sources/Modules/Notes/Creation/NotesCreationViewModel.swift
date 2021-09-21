import SwiftUI
import Combine

final class NotesCreationViewModel: ObservableObject {
  
  private var cancellables: Set<AnyCancellable> = []
  private let api: NotesAPIProtocol
  
  @Published var title = ""
  @Published var body = ""
  @Published var done: (() -> Void)?
  
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
  
  func createNote() { }
}
