//
//  UIMonthSelector.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.08.2021.
//

import UIKit
import SpartaHelpers

class UIMonthSelector<M: PickerValued>: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Public properties

    var inputValues: [M] = []
    var selectedValue: M? {
        didSet {
            nameLabel?.text = selectedValue?.title

//            if let firstIndex = inputValues.firstIndex(where: { $0.title == selectedValue?.title }) {
//                pickerView?.selectRow(firstIndex, inComponent: 1, animated: false)
//            }
        }
    }

    // MARK: - UI

    private var nameLabel: UILabel!
    private var pickerView: UIPickerView!
    private var privateTextField: UITextField!

    // MARK: - Private properties

    private var _onTapClosure: EmptyClosure?
    private var _onChooseClosure: TypeClosure<M>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func apply(selectedValue: M?) {
        nameLabel?.text = selectedValue?.title
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

        backgroundColor = UIColor.plElementBackground
        layer.cornerRadius = 10

        // hidden text field

        privateTextField = UITextField().then { field in

            field.backgroundColor = .clear

            addSubview(field) {
                $0.size.equalTo(0)
                $0.left.top.equalToSuperview()
            }
        }

        let leftArrowImageView = UIImageView().then { imageView in

            imageView.image = UIImage(named: "ic_element_arrow_bottom")
            imageView.tintColor = .primaryText
            imageView.contentMode = .center

            addSubview(imageView) {
                $0.size.equalTo(CGSize(width: 22, height: 18))
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(9)
            }
        }

        nameLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 18)
            label.textAlignment = .center
            label.textColor = UIColor.plMainText

            addSubview(label) {
                $0.centerY.equalTo(leftArrowImageView).offset(-1)
                $0.left.equalTo(leftArrowImageView.snp.right)
                $0.right.equalToSuperview().inset(-3)
            }
        }

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
        privateTextField.becomeFirstResponder()
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
