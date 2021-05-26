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

        guard let value = value, isValidPassword(value) else {
            errorMessage = "Password must be at least 8 characters long, contain a number, a lowercase and a uppercase letter"
            return false
        }

        errorMessage = nil
        return true
    }
}
