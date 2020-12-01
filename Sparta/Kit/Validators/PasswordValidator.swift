//
//  PasswordValidator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

class PasswordValidator: Validator {

    var errorMessage: String?

    func isValid(value: String?) -> Bool {

        guard value != nil else {
            errorMessage = "Password is required and can't be empty."
            return false
        }

        errorMessage = nil
        return true
    }

    func isValidForSetup(value: String?) -> Bool {

        guard let value = value else {
            errorMessage = "Password is required and can't be empty."
            return false
        }

        guard isValidLength(value, range: 6 ... 100) else {
            errorMessage = "Your password must be between 6 and 100 symbols."
            return false
        }

        errorMessage = nil
        return true
    }
}
