//
//  AccountSettingsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit

class AccountSettingsViewController: BaseVMViewController<AccountSettingsViewModel> {

    // MARK: - UI

    private var contentScrollView: UIScrollView!

    private var firstNameField: RoundedTextField!
    private var firstNameLabel: UILabel!

    private var lastNameField: RoundedTextField!
    private var lastNameLabel: UILabel!

    private var phoneNumberCodeField: UITextFieldSelector<TestModel>!
    private var phoneNumberField: RoundedTextField!
    private var phoneNumberLabel: UILabel!

    private var roleField: UITextFieldSelector<TestModel>!
    private var roleLabel: UILabel!

    private var productField: UITextFieldSelector<TestModel>!
    private var productLabel: UILabel!

    private var tradeAreaField: UITextFieldSelector<TestModel>!
    private var tradeAreaLabel: UILabel!

    private var portField: UITextFieldSelector<TestModel>!
    private var portLabel: UILabel!

    private var saveButton: BorderedButton!

    // MARK: - Private properties

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
        setupNavigationUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // view model

        viewModel.delegate = self
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

        // save button

        saveButton = BorderedButton(type: .system).then { button in

            button.setTitle("Save", for: .normal)
            button.layer.cornerRadius = 3

            button.onTap { [unowned self] _ in
//                self.viewModel.userTappedLogin()
//                self.view.endEditing(true)
            }

            scrollViewContent.addSubview(button) {
                $0.top.equalTo(portLabel.snp.bottom).offset(12)
                $0.size.equalTo(CGSize(width: 99, height: 32))
                $0.right.equalTo(portField)
                $0.bottom.equalToSuperview().inset(15)
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = "Account"
    }

    private func setupFirstNameViews(in contentView: UIView) {

        firstNameField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "First Name"

            field.onTextChanged { [unowned self] text in
//                self.viewModel.oldPasswordText = text
            }

            contentView.addSubview(field) {
                $0.top.equalToSuperview().offset(22)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        firstNameLabel = UILabel().then { label in

            label.text = "First Name"
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
            field.placeholder = "Last Name"

            field.onTextChanged { [unowned self] text in
//                self.viewModel.oldPasswordText = text
            }

            contentView.addSubview(field) {
                $0.top.equalTo(firstNameLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        lastNameLabel = UILabel().then { label in

            label.text = "Last Name"
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

            contentView.addSubview(view) {
                $0.size.equalTo(CGSize(width: 90, height: 48))
                $0.top.equalTo(lastNameLabel.snp.bottom).offset(14)
                $0.left.equalTo(lastNameField)
            }
        }

        phoneNumberField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "Mobile Number"

            field.onTextChanged { [unowned self] text in
//                self.viewModel.oldPasswordText = text
            }

            contentView.addSubview(field) {
                $0.top.equalTo(phoneNumberCodeField)
                $0.left.equalTo(phoneNumberCodeField.snp.right).offset(12)
                $0.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        phoneNumberLabel = UILabel().then { label in

            label.text = "Mobile Number"
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

            contentView.addSubview(view) {
                $0.top.equalTo(phoneNumberLabel.snp.bottom).offset(42)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        roleLabel = UILabel().then { label in

            label.text = "Role"
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

            contentView.addSubview(view) {
                $0.top.equalTo(roleLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        productLabel = UILabel().then { label in

            label.text = "Primary Product"
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

            contentView.addSubview(view) {
                $0.top.equalTo(productLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        tradeAreaLabel = UILabel().then { label in

            label.text = "Primary Trade Area"
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

            contentView.addSubview(view) {
                $0.top.equalTo(tradeAreaLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        portLabel = UILabel().then { label in

            label.text = "Primary Port"
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

extension AccountSettingsViewController: AccountSettingsViewModelDelegate {

    func didLoadData() {
        phoneNumberCodeField.inputValues = viewModel.countriesCodes
    }
}
