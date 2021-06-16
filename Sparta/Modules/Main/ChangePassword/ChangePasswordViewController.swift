//
//  ChangePasswordViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2020.
//

import UIKit
import SpartaHelpers

protocol ChangePasswordViewCoordinatorDelegate: AnyObject {
    func changePasswordViewControllerDidFinish(_ controller: ChangePasswordViewController)
}

class ChangePasswordViewController: BaseVMViewController<ChangePasswordViewModel> {

    enum State {
        case initial
        case secondary
    }

    // MARK: - Public properties

    weak var coordinatorDelegate: ChangePasswordViewCoordinatorDelegate?

    // MARK: - Private properties

    private var contentScrollView: UIScrollView!
    private var oldPasswordField: RoundedTextField!
    private var newPasswordField: RoundedTextField!
    private var reNewPasswordField: RoundedTextField!
    private var changePasswordButton: BorderedButton!

    private var addedHeight: CGFloat = .zero

    private var state: State

    // MARK: - Initializers

    init(state: State) {
        self.state = state

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationBar(hide: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

        var topView: UIView

        if state == .initial {
            topView = UILabel().then { label in

                label.text = "It seems this is the first time you log in. Please, change your password."
                label.textColor = .accountMainText
                label.font = .main(weight: .regular, size: 15)
                label.numberOfLines = 0

                scrollView.addSubview(label) {
                    $0.top.equalToSuperview()
                    $0.left.right.equalToSuperview().inset(24)
                }
            }
        } else {
            topView = UIView().then { view in

                view.backgroundColor = .red

                scrollView.addSubview(view) {
                    $0.top.equalToSuperview()
                    $0.height.equalTo(0)
                    $0.left.right.equalToSuperview().inset(24)
                }
            }
        }

        oldPasswordField = RoundedTextField().then { field in

            field.icon = nil
            field.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            field.placeholder = "Enter old password"

            field.textField.isSecureTextEntry = true
            field.showSecurityToggleButton = true

            field.onTextChanged { [unowned self] text in
                self.viewModel.oldPasswordText = text
            }

            scrollView.addSubview(field) {
                $0.top.equalTo(topView.snp.bottom).offset(38)
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

            field.textField.isSecureTextEntry = true
            field.showSecurityToggleButton = true

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

            field.textField.isSecureTextEntry = true
            field.showSecurityToggleButton = true

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
