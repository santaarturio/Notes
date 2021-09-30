import SwiftUI

final class NotesListViewModel: ObservableObject {
  
  private let notesDataBase: NotesDataBaseProtocol
  private let factory: FactoryProtocol = Factory()
  
  lazy var logout: () -> Void = { [weak notesDataBase] in
    KeyHolder.default.flush()
    notesDataBase?.removeAll()
  }
  
  var creationView: AnyView {
    AnyView(factory.makeNotesCreationView())
  }
  
  init(notesDataBase: NotesDataBaseProtocol) {
    self.notesDataBase = notesDataBase
    notesDataBase.setup()
  }
}
