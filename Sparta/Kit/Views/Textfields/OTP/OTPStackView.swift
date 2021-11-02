//
//  OTPStackView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.10.2021.
//

import UIKit

protocol OTPDelegate: class {
    func didChangeValidity(otpStackView: OTPStackView, isValid: Bool)
}

class OTPStackView: UIStackView {

    let textBackgroundColor = UIColor.red.withAlphaComponent(0.2)
    let activeFieldBorderColor = UIColor.white
    var remainingStrStack: [String] = []

    // MARK: - Variables public

    weak var delegate: OTPDelegate?
    var showsWarningColor = false

    var onConfigureTextField: TypeClosure<OTPTextField>?
    var onConfigureFailTextField: TypeClosure<OTPTextField>?

    // MARK: - Variables private

    private let numberOfFields: Int
    private var textFieldsCollection: [OTPTextField] = []

    private lazy var textInputValidator = DecimalInputValidator()

    // MARK: - Initializers

    init(fieldsCount: Int) {

        numberOfFields = fieldsCount

        super.init(frame: .zero)
    }

    required init(coder: NSCoder) {

        numberOfFields = 1

        super.init(coder: coder)
    }

    // MARK: - Public methods

    func configure() {
        setupStackView()
        addOTPFields()
    }

    func showIncorrectUI() {
        applyIncorrectUI()
    }

    func clearIncorrectUI() {
        textFieldsCollection.forEach { textField in
            onConfigureTextField?(textField)
        }
    }

    func clear() {
        textFieldsCollection.forEach { $0.text = "" }
        clearIncorrectUI()
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        guard let firstField = textFieldsCollection.first else { return false }

        return firstField.becomeFirstResponder()
    }

    // MARK: - Private methods

    //Customisation and setting stackView
    private final func setupStackView() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .center
        distribution = .equalSpacing
        spacing = 12
    }

    //Adding each OTPfield to stack view
    private final func addOTPFields() {
        for index in 0 ..< numberOfFields {

            let field = OTPTextField()
            setupTextField(field)
            textFieldsCollection.append(field)
            //Adding a marker to previous field
            index != 0 ? (field.previousTextField = textFieldsCollection[index - 1]) : (field.previousTextField = nil)
            //Adding a marker to next field for the field at index-1
            index != 0 ? (textFieldsCollection[index - 1].nextTextField = field) : ()
        }
        textFieldsCollection[0].becomeFirstResponder()
    }

    //Customisation and setting OTPTextFields
    private final func setupTextField(_ textField: OTPTextField) {
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(textField)

        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = false
        textField.font = .systemFont(ofSize: 40, weight: .bold)
        textField.textColor = .black //.primaryText
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .yes

        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }

        onConfigureTextField?(textField)
    }

    //checks if all the OTPfields are filled
    private final func checkForValidity() {
        for field in textFieldsCollection {
            if let text = field.text, text.isEmpty {
                delegate?.didChangeValidity(otpStackView: self, isValid: false)
                return
            }
        }
        delegate?.didChangeValidity(otpStackView: self, isValid: true)
    }

    final func getOTP() -> String {
        var OTP = ""
        for textField in textFieldsCollection {
            OTP += textField.text ?? ""
        }
        return OTP
    }

    // MARK: - Private methods

    private func applyIncorrectUI() {
        textFieldsCollection.forEach { textField in
            onConfigureFailTextField?(textField)
        }
    }

    private final func autoFillTextField(with string: String) {
        remainingStrStack = string.reversed().compactMap{ String($0) }
        for textField in textFieldsCollection {
            if let charToAdd = remainingStrStack.popLast() {
                textField.text = String(charToAdd)
            } else {
                break
            }
        }
        checkForValidity()
        remainingStrStack = []
    }

}

// MARK: - UITextFieldDelegate
extension OTPStackView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        clearIncorrectUI()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        checkForValidity()
    }

    //switches between OTPTextfields
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        guard let textField = textField as? OTPTextField else { return true }

        defer {

            let newFullText: String = textFieldsCollection.compactMap { return $0.text }.joined() + string
            let isFull: Bool = newFullText.count == numberOfFields

            if !string.isEmpty {
                // Move forward
                textField.text = string
                if let index = textFieldsCollection.firstIndex(where: { $0 === textField }), index < textFieldsCollection.count - 1 {
                    let nextIndex = index + 1
                    textFieldsCollection[nextIndex].becomeFirstResponder()
                    delegate?.didChangeValidity(otpStackView: self, isValid: isFull)
                } else {
                    // Code filled, remove keyboard
                    textField.resignFirstResponder()
                    delegate?.didChangeValidity(otpStackView: self, isValid: isFull)
                }
            } else {

                delegate?.didChangeValidity(otpStackView: self, isValid: isFull)
            }
        }

        if let text = textField.text, !text.isEmpty, !string.isEmpty {
            return false
        }
        return textInputValidator.isDecimal(string) || string.isEmpty

    }
}

