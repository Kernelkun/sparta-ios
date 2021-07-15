//
//  EmailValidator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

class EmailValidator: Validator {

    var errorMessage: String?

    func isValid(value: String?) -> Bool {

        guard let value = value else {
            errorMessage = "Validator.Error.EmptyEmail".localized
            return false
        }

        guard isValidEmail(value) else {
            errorMessage = "Validator.Error.InvalidEmail".localized
            return false
        }

        errorMessage = nil
        return true
    }
}
