//
//  ChangePasswordViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2020.
//

import UIKit
import SpartaHelpers

protocol ChangePasswordViewCoordinatorDelegate: class {
    func changePasswordViewControllerDidFinish(_ controller: ChangePasswordViewController)
}

class ChangePasswordViewController: BaseVMViewController<ChangePasswordViewModel> {

    // MARK: - Public properties

    weak var coordinatorDelegate: ChangePasswordViewCoordinatorDelegate?

    // MARK: - Private properties

    private var contentScrollView: UIScrollView!
    private var oldPasswordField: RoundedTextField!
    private var newPasswordField: RoundedTextField!
    private var reNewPasswordField: RoundedTextField!
    private var changePasswordButton: BorderedButton!

    private var addedHeight: CGFloat = .zero

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        oldPasswordField?.textField.becomeFirstResponder()
    }

    //
    // MARK: Keyboard Management

    override func updateUIForKeyboardPresented(_ presented: Bool, frame: CGRect) {
        super.updateUIForKeyboardPresented(presented, frame: frame)

        if presented && addedHeight.isZero {
            var newSize = contentScrollView.contentSize
            newSize.height += frame.size.height

            addedHeight = frame.size.height

            contentScrollView.contentSize = newSize
        } else if !presented && !addedHeight.isZero {
            var newSize = contentScrollView.contentSize
            newSize.height -= addedHeight

            addedHeight = .zero

            contentScrollView.contentSize = newSize
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        title = "Change password"

        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false

            addSubview(scrollView) {
                $0.top.equalToSuperview().offset(topBarHeight + 12)
                $0.left.bottom.right.equalToSuperview()
            }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear

            contentScrollView.addSubview(view) {
                $0.height.equalTo(self.view.snp.height).offset(-(topBarHeight + 12))
                $0.edges.equalToSuperview()
                $0.centerX.equalToSuperview()
            }
        }

        let scrollView: UIView = scrollViewContent

        let topLabel = UILabel().then { label in

            label.text = "The current password is a default password,\nplease change this password to a more\nsecure value"
            label.textColor = .accountMainText
            label.font = .main(weight: .regular, size: 15)
            label.numberOfLines = 0

            scrollView.addSubview(label) {
                $0.top.equalToSuperview()
                $0.left.right.equalToSuperview().inset(24)
            }
        }

        oldPasswordField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "Enter old password"

            field.onTextChanged { [unowned self] text in
                self.viewModel.oldPasswordText = text
            }

            scrollView.addSubview(field) {
                $0.top.equalTo(topLabel.snp.bottom).offset(38)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        let oldPasswordLabel = UILabel().then { label in

            label.text = "Old password"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            scrollView.addSubview(label) {
                $0.top.equalTo(oldPasswordField.snp.bottom).offset(3)
                $0.left.equalTo(oldPasswordField).offset(3)
            }
        }

        newPasswordField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "Enter new password"

            field.onTextChanged { [unowned self] text in
                self.viewModel.newPasswordText = text
            }

            scrollView.addSubview(field) {
                $0.top.equalTo(oldPasswordLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        let newPasswordLabel = UILabel().then { label in

            label.text = "New password"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            scrollView.addSubview(label) {
                $0.top.equalTo(newPasswordField.snp.bottom).offset(3)
                $0.left.equalTo(newPasswordField).offset(3)
            }
        }

        reNewPasswordField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "Confirm new password"

            field.onTextChanged { [unowned self] text in
                self.viewModel.reNewPasswordText = text
            }

            scrollView.addSubview(field) {
                $0.top.equalTo(newPasswordLabel.snp.bottom).offset(14)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(48)
            }
        }

        _ = UILabel().then { label in

            label.text = "Repeat new password"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            scrollView.addSubview(label) {
                $0.top.equalTo(reNewPasswordField.snp.bottom).offset(3)
                $0.left.equalTo(reNewPasswordField).offset(3)
            }
        }

        oldPasswordField.nextInput = newPasswordField.textField
        newPasswordField.nextInput = reNewPasswordField.textField

        changePasswordButton = BorderedButton(type: .system).then { button in

            button.setTitle("Change password", for: .normal)

            button.onTap { [unowned self] _ in
                self.viewModel.userTappedChangePassword()
            }

            scrollView.addSubview(button) {
                $0.left.right.equalToSuperview().inset(35)
                $0.height.equalTo(50)
                $0.bottom.equalTo(self.contentScrollView.snp.bottom).inset(100).priority(.high)
            }
        }
    }
}

extension ChangePasswordViewController: ChangePasswordViewModelDelegate {

    func didChangeSendingState(_ isSending: Bool) {
        changePasswordButton.isEnabled = !isSending
        changePasswordButton.setIsLoading(isSending, animated: true)
    }

    func cleanupInputErrors() {
    }

    func didCatchAnError(_ description: String) {
        Alert.showOk(title: "Error", message: description, show: self, completion: nil)
    }

    func didFinishSuccess() {
        coordinatorDelegate?.changePasswordViewControllerDidFinish(self)
    }
}
