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
            errorMessage = "Validator.Error.InvalidPassword".localized
            return false
        }

        errorMessage = nil
        return true
    }

    func isValidForSetup(value: String?) -> Bool {

        guard let value = value, isValidPassword(value) else {
            errorMessage = "Validator.Error.NotMatchPasswordReq".localized
            return false
        }

        errorMessage = nil
        return true
    }
}
