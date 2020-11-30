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
            errorMessage = "E-mail is required and can't be empty."
            return false
        }

        guard isValidEmail(value) else {
            errorMessage = "Please enter a valid e-mail address."
            return false
        }

        errorMessage = nil
        return true
    }
}
