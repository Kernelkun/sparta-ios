//
//  OTPTextField.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.10.2021.
//

import UIKit

class OTPTextField: UITextField {

    // MARK: - Public variables

    weak var previousTextField: OTPTextField?
    weak var nextTextField: OTPTextField?

    // MARK: - Public methods

    override public func deleteBackward() {
        guard text?.isEmpty ?? true else {
            text = ""
            return
        }

        previousTextField?.becomeFirstResponder()
    }
}
