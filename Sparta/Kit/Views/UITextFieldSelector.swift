//
//  UITextFieldSelector.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import SpartaHelpers

class UITextFieldSelector<M: PickerValued>: RoundedTextField, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Public properties

    var inputValues: [M] = []
    var selectedValue: M? {
        didSet {
            textField.text = selectedValue?.title
        }
    }

    // MARK: - UI

    private var privateTextField: UITextField!
    private var pickerView = UIPickerView()

    // MARK: - Private properties

    private var _onTapClosure: EmptyClosure?
    private var _onChooseClosure: TypeClosure<M>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func apply(selectedValue: M?, placeholder: String) {
        textField.placeholder = placeholder
        self.selectedValue = selectedValue
    }

    func onTap(completion: @escaping EmptyClosure) {
        _onTapClosure = completion
    }

    func onChooseValue(completion: @escaping TypeClosure<M>) {
        _onChooseClosure = completion
    }

    // MARK: - Private methods

    private func setup() {

        // events

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapEvent)))

        // general UI

        backgroundColor = UIColor.accountFieldBackground
        layer.cornerRadius = 8

        // hidden text field

        privateTextField = UITextField().then { field in

            field.backgroundColor = .clear

            addSubview(field) {
                $0.size.equalTo(0)
                $0.left.right.equalToSuperview()
            }
        }

        // main text field

        let rightViewWithSpace = UIView(frame: CGRect(x: 0, y: 0, width: 43, height: frame.height))

        _ = UIImageView().then { v in

            v.image = UIImage(named: "ic_bottom_chevron")
            v.tintColor = .primaryText
            v.contentMode = .center

            rightViewWithSpace.addSubview(v) { make in
                make.size.equalTo(16)
                make.centerY.equalToSuperview()
                make.left.right.equalToSuperview().inset(12)
            }
        }

        textField.isUserInteractionEnabled = false
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightView = rightViewWithSpace
        textField.rightViewMode = .always

        // picker view

        setupPickerView()
    }

    private func setupPickerView() {
        pickerView = UIPickerView().then { view in

            view.dataSource = self
            view.delegate = self

            let toolBar = UIToolbar().then { toolBar in

                toolBar.barStyle = .default
                toolBar.isTranslucent = true
                toolBar.tintColor = .controlTintActive
                toolBar.sizeToFit()

                let doneButton = UIBarButtonItem(title: "Done",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(toolBarDoneEvent))

                let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

                let cancelButton = UIBarButtonItem(title: "Cancel",
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(toolBarCancelEvent))

                toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
                toolBar.isUserInteractionEnabled = true
            }

            privateTextField.inputAccessoryView = toolBar
            privateTextField.inputView = view
        }
    }

    // MARK: - Events

    @objc
    private func onTapEvent() {
        _onTapClosure?()

        if !inputValues.isEmpty {
            privateTextField.becomeFirstResponder()
        }
    }

    @objc
    func toolBarDoneEvent() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)

        if inputValues.count > selectedRow {
            let selectedValue = inputValues[selectedRow]
            self.selectedValue = selectedValue
            _onChooseClosure?(selectedValue)
        }

        privateTextField.endEditing(true)
    }

    @objc
    func toolBarCancelEvent() {
        privateTextField.endEditing(true)
    }

    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        inputValues.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        inputValues[row].fullTitle
    }
}
