//
//  LoginViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.11.2020.
//

import UIKit
import SpartaHelpers

enum UILoginConstants {

    static let isSmall = UIScreen.isSmallDevice

    static let logoOffset: CGFloat = 38
    static let logoOffsetWithKeyboard: CGFloat = 0

    static let loginFieldOffset: CGFloat = 80
    static let loginFieldOffsetWithKeyboard: CGFloat = isSmall ? 20 : 40

    static let signInButtonOffset: CGFloat = 50
    static let signInButtonOffsetWithKeyboard: CGFloat = isSmall ? 21 : 50
}

protocol LoginViewCoordinatorDelegate: class {
    func loginViewControllerDidFinish(_ controller: LoginViewController)
    func loginViewControllerDidChooseForgotPassword(_ controller: LoginViewController)
}

class LoginViewController: BaseVMViewController<LoginViewModel> {

    // MARK: - Public properties

    weak var coordinatorDelegate: LoginViewCoordinatorDelegate?

    // MARK: - Private properties

    private var loginField: RoundedTextField!
    private var passwordField: RoundedTextField!
    private var signInButton: BorderedButton!
    private var logoView: AvatarView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    //
    // MARK: Keyboard Management

    override func updateUIForKeyboardPresented(_ presented: Bool, frame: CGRect) {
        super.updateUIForKeyboardPresented(presented, frame: frame)

        let logoOffset, loginFieldOffset, signInButtonOffset: CGFloat

        if !presented {
            logoOffset = UILoginConstants.logoOffset
            loginFieldOffset = UILoginConstants.loginFieldOffset
            signInButtonOffset = UILoginConstants.signInButtonOffset
        } else {
            logoOffset = UILoginConstants.logoOffsetWithKeyboard
            loginFieldOffset = UILoginConstants.loginFieldOffsetWithKeyboard
            signInButtonOffset = UILoginConstants.signInButtonOffsetWithKeyboard
        }

        //

        logoView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(topBarHeight + logoOffset)
        }

        loginField.snp.updateConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(loginFieldOffset)
        }

        signInButton.snp.updateConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(signInButtonOffset)
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        _ = UIImageView().then { view in

            view.image = UIImage(named: "sign_in_background")
            view.contentMode = .scaleToFill

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }

        logoView = AvatarView().then { view in

            view.content = .image(UIImage(named: "ic_applogo")!)

            addSubview(view) {
                $0.width.height.equalTo(150)
                $0.top.equalToSuperview().offset(topBarHeight + UILoginConstants.logoOffset)
                $0.centerX.equalToSuperview()
            }
        }

        loginField = RoundedTextField().then { field in

            field.icon = UIImage(named: "ic_field_user")
            field.placeholder = "Email"

            field.onTextChanged { [unowned self] text in
                self.viewModel.loginText = text
            }

            addSubview(field) {
                $0.top.equalTo(logoView.snp.bottom).offset(UILoginConstants.loginFieldOffset)
                $0.left.right.equalToSuperview().inset(35)
                $0.height.equalTo(48)
            }
        }

        passwordField = RoundedTextField().then { field in

            field.icon = UIImage(named: "ic_field_lock")
            field.placeholder = "Password"
            field.textField.isSecureTextEntry = true

            field.onTextChanged { [unowned self] text in
                self.viewModel.passwordText = text
            }

            addSubview(field) {
                $0.top.equalTo(loginField.snp.bottom).offset(21)
                $0.left.right.equalToSuperview().inset(35)
                $0.height.equalTo(48)
            }
        }

        signInButton = BorderedButton(type: .system).then { button in

            button.setTitle("Sign in", for: .normal)

            button.onTap { [unowned self] _ in
                self.viewModel.userTappedLogin()
            }

            addSubview(button) {
                $0.top.equalTo(passwordField.snp.bottom).offset(UILoginConstants.signInButtonOffset)
                $0.left.right.equalToSuperview().inset(35)
                $0.height.equalTo(50)
            }
        }

        _ = TappableButton(type: .system).then { button in

            button.setTitle("Forgot Password", for: .normal)
            button.setTitleColor(.primaryText, for: .normal)

            button.onTap { [unowned self] _ in
                self.coordinatorDelegate?.loginViewControllerDidChooseForgotPassword(self)
            }

            addSubview(button) {
                $0.top.equalTo(signInButton.snp.bottom).offset(20)
                $0.centerX.equalTo(signInButton)
            }
        }

        // When e-mail is entered, automatically jumps to password.
        loginField.nextInput = passwordField.textField
    }
}

extension LoginViewController: LoginViewModelDelegate {

    func didChangeSendingState(_ isSending: Bool) {
        signInButton.isEnabled = !isSending
        signInButton.setIsLoading(isSending, animated: true)
    }

    func cleanupInputErrors() {
    }

    func didCatchAnError(_ description: String) {
        Alert.showOk(title: "Error", message: description, show: self, completion: nil)
    }

    func didFinishSuccess() {
        coordinatorDelegate?.loginViewControllerDidFinish(self)
    }
}
