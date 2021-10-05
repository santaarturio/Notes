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
    self.creatorId = KeyHolder.default.get(.userId)
  }
  
  func configure(title: String?, text: String?) {
    self.id = Date().description
    self.title = title
    self.text = text
    self.date = Date()
    self.isSync = false
    self.creatorId = KeyHolder.default.get(.userId)
  }
}
