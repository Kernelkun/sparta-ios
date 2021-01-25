//
//  SpartaDB.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 22.01.2021.
//

import CoreStore

class SpartaDB {

    // MARK: - Singleton

    static let instance = SpartaDB()

    // MARK: - Public properties

    let dataStack = DataStack()

    // MARK: - Public methods

    func setup() {

        CoreStoreDefaults.dataStack = dataStack
        _ = try? CoreStoreDefaults.dataStack.addStorageAndWait()
    }
}
