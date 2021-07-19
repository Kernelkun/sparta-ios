//
//  Localization.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import Foundation

//
// MARK: - Localizable Protocol

/// This is the main protocol to use in order to get any object localized.
///
/// Generally, the only thing you need to customize is the `rawValue` property.
/// In this case the default `tableName` will be used, which is equal to device system language.
/// In order to override the system language, use `.languageCode` flag of `UserDefaults`.
///
/// The following types already conform the `Localizable` protocol:
/// - String
/// - User.ExpirationOption
/// - User.ExpirationOption.Magnitude
/// - API.Error
public protocol Localizable { // swiftlint:disable:this file_types_order

    /// The value that you actually need to have localized.
    var rawValue: String { get }

    /// The name of the `.strings` file to use. Default is `<system language>.strings`.
    var tableName: String { get }

    /// Localized version of `rawValue`.
    var localized: String { get }
}


public extension Localizable {

    var tableName: String { LocalizationManager.shared.preferredLanguage }

    var localized: String {
        return localized(from: tableName)
    }

    private func localized(from tableName: String) -> String {
        return NSLocalizedString(rawValue, tableName: tableName, value: "**\(self)**", comment: "")
    }
}

//
// MARK: - Adding Localizability to popular types.

extension String: Localizable {
    public var rawValue: String { self }
}

