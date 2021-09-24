//
//  NoteMO+CoreDataClass.swift
//  notes
//
//  Created by Artur Nikolaienko on 24.09.2021.
//
//

import Foundation
import CoreData

@objc(NoteMO)
public class NoteMO: NSManagedObject {

  func configure(note: Note, isSync: Bool) {
    self.id = note.id.string
    self.title = note.title
    self.text = note.text
    self.date = note.date ?? Date()
    self.isSync = isSync
  }
}
