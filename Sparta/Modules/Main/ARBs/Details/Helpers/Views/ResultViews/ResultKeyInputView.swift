//
//  ResultKeyInputView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.01.2021.
//

import UIKit
import SpartaHelpers

class ResultKeyInputView: UIView {

    // MARK: - UI

    private var keyLabel: UILabel!
    var textField: LimitedTextField!

    // MARK: - Private properties

    private var _textChangeClosure: TypeClosure<String>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func apply(key: String, value: String?, onTextChange: @escaping TypeClosure<String>) {
        keyLabel.text = key
        textField.text = value
        _textChangeClosure = onTextChange
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIColor.accountFieldBackground
        layer.cornerRadius = 4

        keyLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 17)
            label.textColor = .accountMainText
            label.textAlignment = .center

            addSubview(label) {
                $0.left.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
            }
        }

        textField = LimitedTextField().then { textField in

            textField.backgroundColor = .mainBackground
            textField.enterType = .numberLimit(range: -199...199)
            textField.textAlignment = .right

            textField.placeholder = ""

            textField.onChanged { [unowned self] in
                self._textChangeClosure?(textField.text ?? "")
            }

            textField.actionDelegate = self

            addSubview(textField) {
                $0.right.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(CGSize(width: 67, height: 28))
            }
        }
    }
}

extension ResultKeyInputView: LimitedTextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
    }

    func textFieldShouldEndEditing(_ textField: UITextField) {
    }

    func textFieldShouldReturn(_ textField: UITextField) {
        textField.endEditing(true)
    }
}
