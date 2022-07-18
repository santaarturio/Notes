//
//  NotesDataBaseStub.swift
//  notes tests
//
//  Created by Artur Nikolaienko on 18.07.2022.
//

import Foundation
import Combine
import SwiftUI

final class NotesDataBaseStub: NotesDataBaseProtocol {
    
    @Published private var notes: [Note] = []
    var notesPublisher: Published<[Note]>.Publisher { $notes }
    
    func updateNote(
        id: String,
        _ configurationsHandler: @escaping (Note) -> Void
    ) { configurationsHandler(Note()) }
    
    func createNote(
        with configurationsHandler: @escaping (Note) -> Void
    ) { configurationsHandler(Note()) }
    
    func allAnsynced(
        _ closure: @escaping ([Note]
        ) -> Void) { closure([]) }
    
    func removeAllNotes() { }
}
