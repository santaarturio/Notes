import Combine

protocol NotesAPIProtocol {
  
  func fetchNotes() -> AnyPublisher<[NoteDTO], Error>
  func createNote(title: String, text: String) -> AnyPublisher<NoteDTO, Error>
}
