//
//  DBUserTarget+CoreDataClass.swift
//  
//
//  Created by Yaroslav Babalich on 22.01.2021.
//
//

import Foundation
import CoreData
import CoreStore
import SpartaHelpers

@objc(DBUserTarget)
public class DBUserTarget: NSManagedObject {

    // MARK: - Static methods

    static func fetch(with id: String) -> DBUserTarget? {
        try? SpartaDB.instance.dataStack.fetchOne(From<DBUserTarget>()
                                                    .where(\.identifier == id))
    }

    static func createOrUpdate(id: String, target: Double, completion: @escaping EmptyClosure) {
        guard let entity = fetch(with: id) else {
            createEntity(with: id, target: target, completion: completion)
            return
        }

        entity.editTarget(target, completion: completion)
    }

    static func createEntity(with id: String, target: Double, completion: @escaping EmptyClosure) {
        SpartaDB.instance.dataStack.perform { transition -> DBUserTarget in
            let entity = transition.create(Into<DBUserTarget>())
            entity.identifier = id
            entity.target = target
            return entity
        } completion: { _ in
            completion()
        }
    }

    // MARK: - Instance methods

    func editTarget(_ newTarget: Double, completion: @escaping EmptyClosure) {
        SpartaDB.instance.dataStack.perform { transaction in
            let editableObject = transaction.edit(self)
            editableObject?.target = newTarget
        } completion: { _ in
            completion()
        }
    }
}
