//
//  NotesAPIStub.swift
//  notes tests
//
//  Created by Artur Nikolaienko on 18.07.2022.
//

import Foundation
import Combine

final class NotesAPIStub: NotesAPIProtocol {
  
  func fetchNotes() -> AnyPublisher<[API.Note], Error> {
    Future<[API.Note], Error> { promise in
      promise(.success([
        API.Note(id: "note_1", title: "Test Note 1 Title", text: "Test Note 1 Text", createdAt: Date())
      ]))
    }.eraseToAnyPublisher()
  }
  
  func createNote(title: String, text: String) -> AnyPublisher<API.Note, Error> {
    Future<API.Note, Error> { promise in
      promise(.success(
        API.Note(id: "note_1", title: "Test Note 1 Title", text: "Test Note 1 Text", createdAt: Date())
      ))
    }.eraseToAnyPublisher()
  }
}
