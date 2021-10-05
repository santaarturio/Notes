import Combine

protocol NotesDataBaseProtocol {
  var notesPublisher: Published<[Note]>.Publisher { get }
  
  func updateNote(id: String, _ configurationsHandler: @escaping (Note) -> Void)
  func createNote(with configurationsHandler: @escaping (Note) -> Void)
  func allAnsynced(_ closure: @escaping ([Note]) -> Void)
  func removeAllNotes()
  func saveAllChanges()
}
