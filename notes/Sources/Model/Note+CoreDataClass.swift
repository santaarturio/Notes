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

  func configure(dto: API.Note, creatorId: String?) {
    self.id = dto.id
    self.title = dto.title
    self.text = dto.text
    self.date = dto.createdAt
    self.isSync = true
    self.creatorId = creatorId
  }
  
  func configure(title: String?, text: String?, creatorId: String?) {
    self.id = Date().description
    self.title = title
    self.text = text
    self.date = Date()
    self.isSync = false
    self.creatorId = creatorId
  }
}
