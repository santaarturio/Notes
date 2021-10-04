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

  func configure(dto: API.Note) {
    self.id = dto.id
    self.title = dto.title
    self.text = dto.subtitle
    self.date = DateFormatter.cached.date(from: dto.date)
    self.isSync = true
  }
}
