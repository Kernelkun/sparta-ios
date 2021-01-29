//
//  LimitedTextField.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.11.2020.
//

import UIKit
import SpartaHelpers

protocol LimitedTextFieldDelegate: class {
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
    func textFieldShouldEndEditing(_ textField: UITextField)
    func textFieldShouldReturn(_ textField: UITextField)
}

class LimitedTextField: UITextField {

    enum TextFieldEnterType {
        case none
        case charactersLimit(range: ClosedRange<Int>, isNumeric: Bool)
        case numberLimit(range: ClosedRange<Double>)
        case numbers(symbolsAfterDot: Int)
        //for example: replacement char -> *, format -> **/** | 21/2021
        case formatted(replacementCharacter: Character, format: NSString)
    }

    // MARK: - Public properties

    weak var actionDelegate: LimitedTextFieldDelegate?

    var enterType: TextFieldEnterType = .charactersLimit(range: 2...64, isNumeric: false) {
        didSet {
            switch enterType {
            case .numberLimit(range: _):
                keyboardType = .default
            default: return
            }
        }
    }

    var initialText: String? {
        didSet {
            text = initialText
            sendActions(for: .editingChanged)
        }
    }

    // MARK: - Variables private

    private var _percentageString = ""
    private var _onChangedClosure: EmptyClosure?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        notification(subscribe: true)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        notification(subscribe: true)
    }

    deinit {
        notification(subscribe: false)
    }

    // MARK: - Public methods

    func onChanged(completion: @escaping EmptyClosure) {
        _onChangedClosure = completion
    }

    // MARK: - Private methods

    private func notification(subscribe: Bool) {
        if subscribe {
            delegate = self
            addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }

    private func makeOnlyDigitsString(string: String) -> String {
        return string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    private func replaceText(replacementCharacter: Character, format: NSString) {
        guard let text = text else { return }

        if !text.isEmpty && format.length > 0 {
            let tempString: NSString = makeOnlyDigitsString(string: text) as NSString

            var finalText: NSString = ""
            var stop = false

            var formatterIndex = 0
            var tempIndex = 0

            while !stop {
                let formattingPatternRange = NSRange(location: formatterIndex, length: 1)

                if format.substring(with: formattingPatternRange) != String(replacementCharacter) {
                    finalText = finalText.appending(format.substring(with: formattingPatternRange)) as NSString
                } else if tempString.length > 0 {
                    let pureStringRange = NSRange(location: tempIndex, length: 1)
                    finalText = finalText.appending(tempString.substring(with: pureStringRange)) as NSString
                    tempIndex += 1
                }

                formatterIndex += 1

                if formatterIndex >= format.length || tempIndex >= tempString.length {
                    stop = true
                }
            }

            self.text = finalText as String
        }
    }

    private func replaceToNumberText() {
        if let text = self.text, !text.isEmpty, let numberString = text.numberString {
            if numberString.last != "."
                && !numberString.hasSuffix(".0") {

                self.text = numberString.toNumberFormattedString
            }
        }
    }

    func replaceToPercentageMask() {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.multiplier = 1
        percentFormatter.minimumFractionDigits = 1
        percentFormatter.maximumFractionDigits = 2

        let numberFromField = NSString(string: _percentageString).doubleValue / 100
        text = percentFormatter.string(from: NSNumber(value: numberFromField))

        _onChangedClosure?()
    }

    private func updateText() {
        switch enterType {
        case .formatted(let replacement, let format):
            replaceText(replacementCharacter: replacement, format: format)

        case .numbers:
            replaceToNumberText()

        default: return
        }
    }

    // MARK: - Events

    @objc private func textFieldDidChange() {
        updateText()
        _onChangedClosure?()
    }
}

extension LimitedTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }

        switch enterType {
        case .charactersLimit(let charactersLimit, let isNumeric):
            let nsStringText = text as NSString
            let newString = nsStringText.replacingCharacters(in: range, with: string)

            if isNumeric {
                if string.isEmpty {
                    return newString.count <= charactersLimit.upperBound
                } else {
                    return newString.count <= charactersLimit.upperBound && !makeOnlyDigitsString(string: string).isEmpty
                }
            } else {
                return newString.count <= charactersLimit.upperBound
            }

        case .numberLimit(range: let numberLimit):

            let validPrefixes = ["-", "+"]

            let nsStringText = text as NSString
            var newString = nsStringText.replacingCharacters(in: range, with: string)

            if newString.isEmpty {
                newString = "0"
            }

            let prefix = String(newString.prefix(1))

            if let number = Double(makeOnlyDigitsString(string: newString)), Double(newString) != nil {

                if validPrefixes.contains(prefix),
                   let newNumber = (prefix + number.toString).toDouble {

                    return numberLimit.contains(newNumber)
                }

                return numberLimit.contains(number)
            } else {

                if newString.count == 1, validPrefixes.contains(prefix) {
                    return true
                }

                return false
            }

        case .numbers(symbolsAfterDot: let symbolsLimit):
            let nsStringText = text as NSString
            let newString = nsStringText.replacingCharacters(in: range, with: string)

            if !string.isEmpty {
                let strings = newString.components(separatedBy: ".")

                if strings.count == 2 {
                    if strings[1].count <= symbolsLimit {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            } else { return true }

        default: return true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        actionDelegate?.textFieldShouldReturn(textField)

        switch enterType {
        case .charactersLimit(range: let charactersLimit, isNumeric: _):
            return textField.text?.count ?? 0 >= charactersLimit.lowerBound
        default: return true
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        actionDelegate?.textFieldShouldEndEditing(textField)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        actionDelegate?.textFieldDidBeginEditing(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        actionDelegate?.textFieldDidEndEditing(textField)
    }
}
