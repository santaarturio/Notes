import SwiftUI
import Combine

final class NotesDetailsViewModel: ObservableObject {
  
  private let note: Note
  
  @Published var title = ""
  @Published var text = ""
  
  init(note: Note) {
    self.note = note
    
    title = note.title ?? ""
    text = note.text ?? ""
  }
}
