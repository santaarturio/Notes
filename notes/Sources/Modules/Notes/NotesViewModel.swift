import SwiftUI

final class NotesViewModel: ObservableObject {
  
  private let api: NotesAPIProtocol
  
  let logout: () -> Void = { KeyHolder.default.flush() }
  
  init(api: NotesAPIProtocol) { self.api = api }
}
