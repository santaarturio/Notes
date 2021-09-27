//
//  Note+CoreDataClass.swift
//  notes
//
//  Created by Artur Nikolaienko on 27.09.2021.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {

  func configure(note: API.Note, isSync: Bool) {
    self.id = note.id
    self.title = note.title
    self.text = note.subtitle
    self.date = DateFormatter.cached.date(from: note.date)
    self.isSync = isSync
  }
}
