//
//  Validator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

protocol Validator {
    var errorMessage: String? { get }
    func isValid(value: String?) -> Bool
}

extension Validator {

    func isValidLength(_ value: String, range: ClosedRange<Int>) -> Bool {
        return range.contains(value.count)
    }

    func isValidEmail(_ value: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]{2,64})+\\.[A-Za-z]{2,64}$"
        return validateString(value, pattern: pattern)
    }

    func isAlphanumeric(_ value: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._-]+$"
        return validateString(value, pattern: pattern)
    }

    func isAlphanumericLowercased(_ value: String) -> Bool {
        let pattern = "^[0-9a-z_-]+$"
        return validateString(value, pattern: pattern)
    }

    func containsAtLeastOneLetter(_ value: String) -> Bool {
        let pattern = "[A-Za-z]"
        return validateString(value, pattern: pattern)
    }

    func containsAtLeastOneSymbol(_ value: String) -> Bool {
        let pattern = "[0-9._-]"
        return validateString(value, pattern: pattern)
    }

    //

    func validateString(_ value: String, pattern: String) -> Bool {

        guard value.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil else {
            return false
        }

        return true
    }
}

