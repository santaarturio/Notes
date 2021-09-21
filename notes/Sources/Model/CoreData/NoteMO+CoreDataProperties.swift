//
//  NoteMO+CoreDataProperties.swift
//  notes
//
//  Created by Artur Nikolaienko on 21.09.2021.
//
//

import Foundation
import CoreData


extension NoteMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteMO> {
        return NSFetchRequest<NoteMO>(entityName: "NoteMO")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?

}

extension NoteMO : Identifiable {

}
