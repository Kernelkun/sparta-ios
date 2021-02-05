//
//  DBUserTarget+CoreDataProperties.swift
//  
//
//  Created by Yaroslav Babalich on 22.01.2021.
//
//

import Foundation
import CoreData

extension DBUserTarget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBUserTarget> {
        return NSFetchRequest<DBUserTarget>(entityName: "DBUserTarget")
    }

    @NSManaged public var target: Double
    @NSManaged public var identifier: String
}
