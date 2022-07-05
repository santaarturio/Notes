import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

final class NotesAPI: NotesAPIProtocol {
  
  private let firestore = Firestore.firestore()
  private var userID: String? { Auth.auth().currentUser?.uid }
  
  func fetchNotes() -> AnyPublisher<[API.Note], Error> {
    firestore
      .collection("Users")
      .document(userID ?? "")
      .collection("Notes")
      .getDocuments()
      .map(\.documents)
      .map { documents in documents.compactMap { doc in try? doc.data(as: API.Note.self) } }
      .eraseToAnyPublisher()
  }
  
  func createNote(
    title: String,
    text: String
  ) -> AnyPublisher<API.Note, Error> {
    let note = API.Note(title: title, text: text)
    return firestore
      .collection("Users")
      .document(userID ?? "")
      .collection("Notes")
      .document(note.id)
      .setData(from: note)
      .map { note }
      .eraseToAnyPublisher()
  }
}

private extension API.Note {
  
  init(
    title: String,
    text: String
  ) {
    self.id = UUID().uuidString
    self.title = title
    self.text = text
    self.createdAt = Date()
  }
}
