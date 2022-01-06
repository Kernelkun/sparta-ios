//
//  SettingsMobileFieldView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2022.
//

import UIKit
import PhoneNumberKit
import SpartaHelpers

class SettingsMobileFieldView: UIView {

    // MARK: - Private properties

    private let mobileParser: MobileParser

    // MARK: - UI

    private var flagSelector: SettingsCountrySelectorView!
    private var phoneNumberTextField: PhoneNumberTextField!

    private var _onChangeNumber: TypeClosure<PhoneNumber?>?

    // MARK: - Initializers

    init() {
        mobileParser = MobileParser(defaultCode: PhoneNumberKit.defaultRegionCode())
        super.init(frame: .zero)

        mobileParser.delegate = self
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func apply(phoneNumber: PhoneNumber?) {
        guard let phoneNumber = phoneNumber else { return }

        mobileParser.apply(phoneNumber: phoneNumber)
        phoneNumberTextField.text = MobileParser.generateNationalNumber(from: phoneNumber)
    }

    func onChangeNumber(completion: @escaping TypeClosure<PhoneNumber?>) {
        _onChangeNumber = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        flagSelector = SettingsCountrySelectorView(phoneNumberKit: mobileParser.phoneNumberKit).then { selectorView in

            selectorView.delegate = self

            addSubview(selectorView) {
                $0.left.top.bottom.equalToSuperview()
                $0.width.equalTo(120)
            }
        }

        phoneNumberTextField = PhoneNumberTextField().then { textField in

            textField.withPrefix = false
            textField.withExamplePlaceholder = true
            textField.backgroundColor = UIColor.accountFieldBackground
            textField.layer.cornerRadius = 8
            textField.addTarget(self, action: #selector(numberFieldDidChangeValue), for: .editingChanged)

            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
            textField.leftViewMode = .always

            addSubview(textField) {
                $0.top.bottom.right.equalToSuperview()
                $0.left.equalTo(flagSelector.snp.right).offset(12)
            }
        }

        if let country = mobileParser.country {
            updateUI(for: country)
        }
    }

    private func updateUI(for country: MobileParser.Country) {
        flagSelector.country = country

        phoneNumberTextField.partialFormatter.defaultRegion = country.code
        phoneNumberTextField.updatePlaceholder()
    }

    // MARK: - Events

    @objc
    private func numberFieldDidChangeValue() {
        _onChangeNumber?(phoneNumberTextField.phoneNumber)
    }
}

extension SettingsMobileFieldView: SettingsCountrySelectorViewDelegate {

    func settingsCountrySelectorViewDidChooseCountry(_ view: SettingsCountrySelectorView, country: CMPViewController.Country) {
        mobileParser.updateCountryCode(country.code)
    }
}

extension SettingsMobileFieldView: MobileParserDelegate {

    func mobileParserDidUpdateDataToNewCountry(_ parser: MobileParser, country: MobileParser.Country?) {
        guard let country = country else { return }

        updateUI(for: country)
    }
}
