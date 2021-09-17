
protocol NotesAPIProtocol {
  
  func fetchNotes(_ completion: @escaping (Result<[NoteDTO], Error>) -> Void)
  func createNote(title: String?, text: String?, completion: @escaping (Result<NoteDTO, Error>) -> Void)
}
