//
//  UserDefaults+Sparta.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import UIKit

public enum UserDefaultsKey: String {

    case launchCount
    case languageCode
}

public extension UserDefaults {

    typealias Key = UserDefaultsKey

    static func set(_ value: Any?, forKey key: Key, synchronize: Bool = true) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
        if synchronize { UserDefaults.standard.synchronize() }
    }

    static func remove(forKey key: Key, synchronize: Bool = true) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        if synchronize { UserDefaults.standard.synchronize() }
    }

    static func value(forKey key: Key) -> Any? {
        return UserDefaults.standard.value(forKey: key.rawValue)
    }

    static func string(forKey key: Key) -> String? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? String
    }

    static func bool(forKey key: Key) -> Bool? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? Bool
    }

    static func int(forKey key: Key) -> Int? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? Int
    }

    static func cgFloat(forKey key: Key) -> CGFloat? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? CGFloat
    }

    static func float(forKey key: Key) -> Float? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? Float
    }

    static func double(forKey key: Key) -> Double? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? Double
    }
}

public extension UserDefaults {

    static var isFirstLaunch: Bool {
        return (UserDefaults.int(forKey: .launchCount) ?? -1) == 1
    }
}
