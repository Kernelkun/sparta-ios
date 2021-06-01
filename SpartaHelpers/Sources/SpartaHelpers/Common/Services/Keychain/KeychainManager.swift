//
//  KeychainManager.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import Foundation
import KeychainAccess

/// String that represents keychain storage identifier.
public typealias KeychainStorage = String

/// String that represents key by which object will be stored in the keychain.
public typealias KeychainKey = String

//
// MARK: - KeychainManager

/// Represents keychain. Uses `KeychainAccess` to store and retrieve data from the keychain.
public final class KeychainManager {

    //
    // MARK: - Private Stuff

    private let allStorages: [KeychainStorage] = [.userData]

    public init() {}

    //
    // MARK: - Public Accessors

    /**
     Save object to keychain.

     - Parameter object: String object that will be saved.
     - Parameter key: Key by which object will be added to a keychain.
     - Parameter storage: String identifier of storage where object will be stored.
     */
    public func save(_ object: String, as key: KeychainKey, to storage: KeychainStorage) throws {
        let storedData = Keychain(service: storage)
        try? storedData.set(object, key: key)
    }

    /**
     Save object to the keychain.

     - Parameter object: Data object that will be saved.
     - Parameter key: Key by which object will be added to a keychain.
     - Parameter storage: String identifier of storage where object will be stored.
     */
    public func save(_ object: Data, as key: KeychainKey, to storage: KeychainStorage) throws {
        let storedData = Keychain(service: storage)
        try? storedData.set(object, key: key)
    }

    /**
     Get `String` object from the keychain.

     - Parameter key: Key by which object was stored.
     - Parameter storage: String identifier of storage where object was stored.
     */
    public func retrieve(_ key: KeychainKey, from storage: KeychainStorage) -> String? {
        let storedData = Keychain(service: storage)
        return try? storedData.getString(key)
    }

    /**
     Get `Data` object from the keychain.

     - Parameter key: Key by which object was stored.
     - Parameter storage: String identifier of storage where object was stored.
     */
    public func retrieve(_ key: KeychainKey, from storage: KeychainStorage) -> Data? {
        let storedData = Keychain(service: storage)

        do {
            let data = try storedData.getData(key)
            return data
        } catch { return nil }
    }

    /** Wipes all data across all the storages */
    public func reset() throws {
        try allStorages.forEach { try reset(storage: $0) }
    }

    /** Wipes all data in the specified storages */
    public func reset(storage: KeychainStorage) throws {
        let storedData = Keychain(service: storage)
        try storedData.removeAll()
    }

    /** Wipes the data in the specified storages for a specified key */
    public func reset(_ key: KeychainKey, in storage: KeychainStorage) throws {
        let storedData = Keychain(service: storage)
        try storedData.remove(key)
    }
}
