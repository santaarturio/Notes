
protocol NotesAPIProtocol {
  
  func fetchNotes() -> [Note]
  func createNote(title: String?, text: String?)
  func deleteNote(id: Note.ID)
}
