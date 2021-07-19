//
//  AccountSettingsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import SpartaHelpers

class AccountSettingsViewController: BaseVMViewController<AccountSettingsViewModel> {

    // MARK: - UI

    private var contentScrollView: UIScrollView!

    private var firstNameField: RoundedTextField!
    private var firstNameLabel: UILabel!

    private var lastNameField: RoundedTextField!
    private var lastNameLabel: UILabel!

    private var phoneNumberCodeField: UITextFieldSelector<CountryCodeModel>!
    private var phoneNumberField: RoundedTextField!
    private var phoneNumberLabel: UILabel!

    private var roleField: UITextFieldSelector<PickerIdValued<Int>>!
    private var roleLabel: UILabel!

    private var productField: UITextFieldSelector<PickerIdValued<Int>>!
    private var productLabel: UILabel!

    private var tradeAreaField: UITextFieldSelector<PickerIdValued<Int>>!
    private var tradeAreaLabel: UILabel!

    private var portField: UITextFieldSelector<PickerIdValued<Int>>!
    private var portLabel: UILabel!

    private var saveButton: BorderedButton!

    // MARK: - Private properties

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
        setupNavigationUI()

        // view model

        viewModel.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {

        view.backgroundColor = UIColor(hex: 0x1D1D1D).withAlphaComponent(0.94)

        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false

            addSubview(scrollView) {
                $0.top.equalToSuperview().offset(topBarHeight)
                $0.left.bottom.right.equalToSuperview()
            }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear

            contentScrollView.addSubview(view) {
                $0.left.top.right.equalToSuperview()
                $0.bottom.lessThanOrEqualToSuperview().priority(.high)
                $0.centerX.equalToSuperview()
            }
        }

        // first name views

        setupFirstNameViews(in: scrollViewContent)

        // last name views

        setupLastNameViews(in: scrollViewContent)

        // phone number view

        setupPhoneNumberViews(in: scrollViewContent)

        // role views

        setupRoleViews(in: scrollViewContent)

        // products view

        setupProductViews(in: scrollViewContent)

        // trade area views

        setupTradeAreaViews(in: scrollViewContent)

        // port views

        setupPortViews(in: scrollViewContent)

        // change password view

        let changePasswordView = LineButtonView(title: "ChangePassword.Title".localized).then { view in

            view.onTap { [unowned self] in
                let vc = ChangePasswordViewController(state: .secondary)
                vc.coordinatorDelegate = self

                self.navigationController?.pushViewController(vc, animated: true)
            }

            addSubview(view) {
                $0.top.equalTo(portLabel.snp.bottom).offset(42)
                $0.left.right.equalToSuperview()
            }
        }

        // save button

        saveButton = BorderedButton(type: .system).then { button in

            button.setTitle("Save.Title".localized, for: .normal)
            button.layer.cornerRadius = 3

            button.onTap { [unowned self] _ in
                self.viewModel.saveData()
            }

            scrollViewContent.addSubview(button) {
                $0.top.equalTo(changePasswordView.snp.bottom).offset(12)
                $0.size.equalTo(CGSize(width: 99, height: 32))
                $0.right.equalTo(portField)
                $0.bottom.equalToSuperview().inset(15)
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = "SettingsPage.List.Account.Title".localized
    }

    private func setupFirstNameViews(in contentView: UIView) {

        firstNameField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "SettingsPage.Account.FirstName.Placeholder".localized

            field.onTextChanged { [unowned self] text in
                self.viewModel.selectedFirstName = text
            }

            contentView.addSubview(field) {
                $0.top.equalToSuperview().offset(22)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        firstNameLabel = UILabel().then { label in

            label.text = "SettingsPage.Account.FirstName.SubTitle".localized
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(firstNameField.snp.bottom).offset(3)
                $0.left.equalTo(firstNameField).offset(3)
            }
        }
    }

    private func setupLastNameViews(in contentView: UIView) {
        lastNameField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "SettingsPage.Account.LastName.Placeholder".localized

            field.onTextChanged { [unowned self] text in
                self.viewModel.selectedLastName = text
            }

            contentView.addSubview(field) {
                $0.top.equalTo(firstNameLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        lastNameLabel = UILabel().then { label in

            label.text = "SettingsPage.Account.LastName.SubTitle".localized
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(lastNameField.snp.bottom).offset(3)
                $0.left.equalTo(lastNameField).offset(3)
            }
        }
    }

    private func setupPhoneNumberViews(in contentView: UIView) {

        phoneNumberCodeField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] selectedValue in
                self.viewModel.selectedCountryCode = selectedValue
            }

            contentView.addSubview(view) {
                $0.size.equalTo(CGSize(width: 95, height: 48))
                $0.top.equalTo(lastNameLabel.snp.bottom).offset(14)
                $0.left.equalTo(lastNameField)
            }
        }

        phoneNumberField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "SettingsPage.Account.MobileNumber.Placeholder".localized
            field.textField.keyboardType = .phonePad

            field.onTextChanged { [unowned self] text in
                self.viewModel.selectedPhoneNumber = text
            }

            contentView.addSubview(field) {
                $0.top.equalTo(phoneNumberCodeField)
                $0.left.equalTo(phoneNumberCodeField.snp.right).offset(12)
                $0.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        phoneNumberLabel = UILabel().then { label in

            label.text = "SettingsPage.Account.MobileNumber.SubTitle".localized
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(phoneNumberCodeField.snp.bottom).offset(3)
                $0.left.equalTo(phoneNumberCodeField).offset(3)
            }
        }
    }

    private func setupRoleViews(in contentView: UIView) {

        roleField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] value in
                self.viewModel.selectedUserRole = value
                self.viewModel.reloadTradesOptions()
            }

            contentView.addSubview(view) {
                $0.top.equalTo(phoneNumberLabel.snp.bottom).offset(42)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        roleLabel = UILabel().then { label in

            label.text = "SettingsPage.Account.Role.SubTitle".localized
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(roleField.snp.bottom).offset(3)
                $0.left.equalTo(roleField).offset(3)
            }
        }
    }

    private func setupProductViews(in contentView: UIView) {

        productField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] value in
                self.viewModel.selectedPrimaryProduct = value
                self.viewModel.reloadTradesOptions()
            }

            contentView.addSubview(view) {
                $0.top.equalTo(roleLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        productLabel = UILabel().then { label in

            label.text = "SettingsPage.Account.PrimaryProduct.SubTitle".localized
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(productField.snp.bottom).offset(3)
                $0.left.equalTo(productField).offset(3)
            }
        }
    }

    private func setupTradeAreaViews(in contentView: UIView) {

        tradeAreaField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] value in
                self.viewModel.selectedTradeArea = value
                self.viewModel.reloadTradesOptions()
            }

            contentView.addSubview(view) {
                $0.top.equalTo(productLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        tradeAreaLabel = UILabel().then { label in

            label.text = "SettingsPage.Account.PrimaryTradeArea.SubTitle".localized
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(tradeAreaField.snp.bottom).offset(3)
                $0.left.equalTo(tradeAreaField).offset(3)
            }
        }
    }

    private func setupPortViews(in contentView: UIView) {

        portField = UITextFieldSelector().then { view in

            view.onChooseValue { [unowned self] value in
                self.viewModel.selectedPort = value
                self.viewModel.reloadTradesOptions()
            }

            contentView.addSubview(view) {
                $0.top.equalTo(tradeAreaLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        portLabel = UILabel().then { label in

            label.text = "SettingsPage.Account.PrimaryPort.SubTitle".localized
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.top.equalTo(portField.snp.bottom).offset(3)
                $0.left.equalTo(portField).offset(3)
            }
        }
    }
}

extension AccountSettingsViewController: ChangePasswordViewCoordinatorDelegate {

    func changePasswordViewControllerDidFinish(_ controller: ChangePasswordViewController) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AccountSettingsViewController: AccountSettingsViewModelDelegate {

    func didLoadData() {

        // first/last names

        firstNameField.textField.initialText = viewModel.selectedFirstName
        lastNameField.textField.initialText = viewModel.selectedLastName

        // phone number fields

        phoneNumberCodeField.inputValues = viewModel.countriesCodes
        phoneNumberCodeField.apply(selectedValue: viewModel.selectedCountryCode,
                                   placeholder: "SettingsPage.Account.MobileNumber.Code.Placeholder".localized)

        phoneNumberField.textField.initialText = viewModel.selectedPhoneNumber
    }

    func didReloadTradeOptions() {

        // role fields

        roleField.inputValues = viewModel.userRoles
        roleField.apply(selectedValue: viewModel.selectedUserRole,
                        placeholder: "SettingsPage.Account.Role.Placeholder".localized)

        // primary products

        productField.inputValues = viewModel.products
        productField.apply(selectedValue: viewModel.selectedPrimaryProduct,
                           placeholder: "SettingsPage.Account.PrimaryProduct.Placeholder".localized)

        // trade area

        tradeAreaField.inputValues = viewModel.tradeAreas
        tradeAreaField.apply(selectedValue: viewModel.selectedTradeArea,
                             placeholder: "SettingsPage.Account.PrimaryTradeArea.Placeholder".localized)

        // ports

        portField.inputValues = viewModel.ports
        portField.apply(selectedValue: viewModel.selectedPort,
                        placeholder: "SettingsPage.Account.PrimaryPort.Placeholder".localized)
    }

    func didCatchAnError(_ error: String) {
        Alert.showOk(title: "Alert.Error.Title".localized, message: error, show: self, completion: nil)
    }

    func didChangeSendingState(_ isSending: Bool, for state: AccountSettingsViewModel.LoadingState) {
        switch state {
        case .save:

            saveButton.isEnabled = !isSending
            saveButton.setIsLoading(isSending, animated: true)

        case .load:

            loadingView(isAnimating: isSending)
        }
    }
}
