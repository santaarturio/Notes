import Moya

class NotesAPI: NotesAPIProtocol {
  
  static let shared = NotesAPI()
  
  func fetchNotes() -> [Note] { [] }
  
  func createNote(title: String?, text: String?) { }
  
  func deleteNote(id: Note.ID) { }
}
