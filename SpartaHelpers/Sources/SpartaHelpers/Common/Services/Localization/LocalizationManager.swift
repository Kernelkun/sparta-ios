//
//  LocalizationManager.swift
//  
//
//  Created by Yaroslav Babalich on 15.07.2021.
//

import Foundation

/// The private manager of this scope that holds "Supported Languages" and "Current Language" logic.
class LocalizationManager {

    // MARK: - Singleton

    static let shared = LocalizationManager()
    private init() { }

    //
    // MARK: - Private Stuff

    private static let supportedLanguages: [String] = ["en"]
    private static let defaultLanguage: String = supportedLanguages[0]

    //
    // MARK: - Public Accessors

    var preferredLanguage: String {

        //
        // In case user selected a language in Settings, we are forcing this language to be used.

        if let languageCode = UserDefaults.string(forKey: .languageCode) {
            return languageCode
        }

        //
        // Otherwise, we're trying to get the default system language.

        for language in Locale.preferredLanguages {

            let locale = Locale(identifier: language)

            guard let language = locale.languageCode else { continue }
            guard supports(language: language) else { continue }

            return language
        }

        return LocalizationManager.defaultLanguage
    }

    private func supports(language code: String) -> Bool {
        return LocalizationManager.supportedLanguages.contains(code)
    }
}
