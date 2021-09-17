import SwiftUI

final class CreateNoteViewModel: ObservableObject {
  
  private let api: NotesAPIProtocol
  
  init(api: NotesAPIProtocol) { self.api = api }
}
