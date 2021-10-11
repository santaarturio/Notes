import Combine

protocol NotesAPIProtocol {
  
  func fetchNotes() -> AnyPublisher<[API.Note], Error>
  func createNote(title: String, text: String) -> AnyPublisher<API.Note, Error>
}
