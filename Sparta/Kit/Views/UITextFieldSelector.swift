//
//  UITextFieldSelector.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import SpartaHelpers

struct UITextFieldSelectorConfigurator {

    let leftSpace: CGFloat
    let imageRightSpace: CGFloat
    let imageLeftSpace: CGFloat
    let image: UIImage?
    let imageSize: CGSize
    let cornerRadius: CGFloat
    let defaultTextAttributes: [NSAttributedString.Key: Any]

    init(
        leftSpace: CGFloat = 16,
        imageRightSpace: CGFloat = 12,
        imageLeftSpace: CGFloat = 12,
        image: UIImage? = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17)),
        imageSize: CGSize = CGSize(width: 17.8, height: 10.2),
        cornerRadius: CGFloat = 8,
        defaultTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.primaryText,
                                                                .font: UIFont.main(weight: .regular, size: 15)]
    ) {
        self.leftSpace = leftSpace
        self.imageRightSpace = imageRightSpace
        self.imageLeftSpace = imageLeftSpace
        self.image = image
        self.imageSize = imageSize
        self.cornerRadius = cornerRadius
        self.defaultTextAttributes = defaultTextAttributes
    }
}

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

    private let configurator: UITextFieldSelectorConfigurator

    private var _onTapClosure: EmptyClosure?
    private var _onChooseClosure: TypeClosure<M>?

    // MARK: - Initializers

    init(configurator: UITextFieldSelectorConfigurator = UITextFieldSelectorConfigurator()) {
        self.configurator = configurator
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
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
        layer.cornerRadius = configurator.cornerRadius

        // hidden text field

        privateTextField = UITextField().then { field in

            field.backgroundColor = .clear

            addSubview(field) {
                $0.size.equalTo(0)
                $0.left.right.equalToSuperview()
            }
        }

        // main text field

        let totalWidth = configurator.imageLeftSpace + configurator.imageRightSpace + configurator.imageSize.width

        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: totalWidth, height: frame.height))

        _ = UIImageView().then { imageView in

            imageView.image = configurator.image
            imageView.tintColor = .neutral35
            imageView.contentMode = .center

            rightView.addSubview(imageView) {
                $0.size.equalTo(configurator.imageSize)
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().inset(configurator.imageRightSpace)
                $0.left.equalToSuperview().offset(configurator.imageLeftSpace)
            }
        }

        textField.isUserInteractionEnabled = false

        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: configurator.leftSpace, height: 0))
        textField.leftViewMode = .always
        //
        textField.rightView = rightView
        textField.rightViewMode = .always
        //
        textField.defaultTextAttributes = configurator.defaultTextAttributes

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
