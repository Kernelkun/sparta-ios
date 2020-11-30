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

        guard let _ = value else {
            errorMessage = "Password is required and can't be empty."
            return false
        }

        errorMessage = nil
        return true
    }
}

