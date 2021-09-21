import SwiftUI

final class NotesListViewModel: ObservableObject {
  
  private let api: NotesAPIProtocol
  private let factory: FactoryProtocol = Factory()
  
  let logout: () -> Void = { KeyHolder.default.flush() }
  var creationView: AnyView {
    AnyView(factory.makeNotesCreationView())
  }
  
  @Published var notes: [Note] = []
  
  init(api: NotesAPIProtocol) { self.api = api }
}
