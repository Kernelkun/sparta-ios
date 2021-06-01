//
//  RoundedTextField.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.11.2020.
//

import UIKit
import SpartaHelpers

protocol RoundedTextFieldDelegate: AnyObject {
    func roundedTextFieldDidBeginEditing(_ textField: RoundedTextField)
    func roundedTextFieldDidEndEditing(_ textField: RoundedTextField)
}

class RoundedTextField: UIView {

    //
    // MARK: - Public Accessors

    weak var delegate: RoundedTextFieldDelegate?

    weak var nextInput: UITextField?

    var icon: UIImage? {
        didSet {
            if icon != nil {
                leftViewIcon.image = icon
                leftViewWithSpace.layoutIfNeeded()
                textField.leftView = leftViewWithSpace
            } else {
                leftViewIcon.image = nil
                leftViewWithSpace.layoutIfNeeded()
                textField.leftView = nil
            }
        }
    }

    var placeholder: String? {
        didSet {

            guard let placeholder = placeholder else {
                textField.placeholder = nil
                return
            }

            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: UIColor.secondaryText,
                             .font: UIFont.main(weight: .regular, size: 15)]
            )
        }
    }

    var showSecurityToggleButton: Bool = false {
        didSet {
            switch showSecurityToggleButton {
            case true:
                securityToggleButton.isSelected = !textField.isSecureTextEntry
                textField.rightView = securityToggleButton
                textField.rightViewMode = .always

            case false:
                textField.rightView = nil
                textField.rightViewMode = .never
            }
        }
    }

    //
    // MARK: - Popup Data

    var popupText: String?
    var popupSource: UIViewController?

    func onTextChanged(completion: @escaping StringClosure) {
        textField.onChanged { [unowned self] in completion(self.textField.text ?? "") }
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    //
    // MARK: - Private Stuff

    private(set) var textField: LimitedTextField!
    private var errorLabel: UILabel!

    private var leftViewWithSpace: UIView!
    private var leftViewIcon: UIImageView!

    private lazy var securityToggleButton = TappableButton().then { v in

        let configuration = UIImage.SymbolConfiguration(pointSize: 16, weight: .light)
        let image = UIImage(systemName: "eye.fill", withConfiguration: configuration)
        let selectedImage = UIImage(systemName: "eye.slash.fill", withConfiguration: configuration)

        v.setImage(image, for: .normal)
        v.setImage(selectedImage, for: .selected)
        v.setImage(selectedImage, for: [.selected, .highlighted])

        v.tintColor = .primaryText

        v.onTap { [unowned self] sender in
            sender.isSelected.toggle()
            self.textField.isSecureTextEntry = !sender.isSelected
        }

        addSubview(v) { $0.width.height.equalTo(44) }
    }

    //
    // MARK: - View Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    //
    // MARK: - Private Stuff

    private func setupUI() {

        // general

        backgroundColor = UIColor.accountFieldBackground
        layer.cornerRadius = 8

        // text field

        textField = LimitedTextField().then { v in

            v.autocapitalizationType = .none
            v.autocorrectionType = .no
            v.actionDelegate = self

            v.defaultTextAttributes = [.foregroundColor: UIColor.primaryText,
                                       .font: UIFont.main(weight: .regular, size: 15)]

            //

            leftViewWithSpace = UIView(frame: CGRect(x: 0, y: 0, width: 43, height: frame.height))

            leftViewIcon = UIImageView().then { v in

                v.tintColor = .primaryText
                v.contentMode = .center

                leftViewWithSpace.addSubview(v) { make in
                    make.size.equalTo(16)
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().offset(15)
                    make.right.equalToSuperview().inset(12)
                }
            }

            v.leftViewMode = .always
            v.leftView = leftViewWithSpace

            //

            addSubview(v) {
                $0.edges.equalToSuperview()
            }
        }
    }
}

extension RoundedTextField: LimitedTextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.roundedTextFieldDidBeginEditing(self)

        onMainThread(delay: 0.3) {
            if textField.isFirstResponder,
                let popupText = self.popupText?.trimmed.nullable,
                let popupSource = self.popupSource {

                let presentingRect = CGRect(x: 40, y: -2, width: 1, height: self.bounds.height - 8)

                let vc = PopupTextViewController(text: popupText)
                vc.popup(from: self.convert(presentingRect, to: popupSource.view), in: popupSource)
            }
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) {
        popupSource?.dismiss(animated: true, completion: nil)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        // Shitty workaround. Hi, Apple!
        textField.layoutIfNeeded()

        delegate?.roundedTextFieldDidEndEditing(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) {

        if let nextInput = nextInput {
            nextInput.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
}

extension RoundedTextFieldDelegate {
    func roundedTextFieldDidBeginEditing(_ textField: RoundedTextField) { }
    func roundedTextFieldDidEndEditing(_ textField: RoundedTextField) { }
}
