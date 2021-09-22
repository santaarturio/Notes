import Combine

protocol NotesAPIProtocol {
  
  func fetchNotes() -> Future<[NoteDTO], Error>
  func createNote(title: String, text: String) -> Future<NoteDTO, Error>
}
