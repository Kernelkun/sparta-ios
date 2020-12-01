//
//  ForgotPasswordViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import UIKit
import SpartaHelpers

enum UIForgotPasswordConstants {

    static let isSmall = UIScreen.isSmallDevice

    static let logoOffset: CGFloat = 38
    static let logoOffsetWithKeyboard: CGFloat = 0

    static let loginFieldOffset: CGFloat = 141
    static let loginFieldOffsetWithKeyboard: CGFloat = isSmall ? 80 : 100

    static let signInButtonOffset: CGFloat = 50
    static let signInButtonOffsetWithKeyboard: CGFloat = isSmall ? 21 : 50
}

protocol ForgotPasswordViewCoordinatorDelegate: class {
    func forgotPasswordViewControllerDidFinish(_ controller: ForgotPasswordViewController)
    func forgotPasswordViewControllerDidTapLogin(_ controller: ForgotPasswordViewController)
}

class ForgotPasswordViewController: BaseVMViewController<ForgotPasswordViewModel> {

    // MARK: - Public properties

    weak var coordinatorDelegate: ForgotPasswordViewCoordinatorDelegate?

    // MARK: - Private properties

    private var loginField: RoundedTextField!
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
            logoOffset = UIForgotPasswordConstants.logoOffset
            loginFieldOffset = UIForgotPasswordConstants.loginFieldOffset
            signInButtonOffset = UIForgotPasswordConstants.signInButtonOffset
        } else {
            logoOffset = UIForgotPasswordConstants.logoOffsetWithKeyboard
            loginFieldOffset = UIForgotPasswordConstants.loginFieldOffsetWithKeyboard
            signInButtonOffset = UIForgotPasswordConstants.signInButtonOffsetWithKeyboard
        }

        //

        logoView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(topBarHeight + logoOffset)
        }

        loginField.snp.updateConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(loginFieldOffset)
        }

        signInButton.snp.updateConstraints {
            $0.top.equalTo(loginField.snp.bottom).offset(signInButtonOffset)
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
                $0.top.equalToSuperview().offset(topBarHeight + UIForgotPasswordConstants.logoOffset)
                $0.centerX.equalToSuperview()
            }
        }

        loginField = RoundedTextField().then { field in

            field.icon = UIImage(named: "ic_field_user")
            field.placeholder = "Email"
            field.backgroundColor = .authFieldBackground

            field.onTextChanged { [unowned self] text in
                self.viewModel.loginText = text
            }

            addSubview(field) {
                $0.top.equalTo(logoView.snp.bottom).offset(UIForgotPasswordConstants.loginFieldOffset)
                $0.left.right.equalToSuperview().inset(35)
                $0.height.equalTo(48)
            }
        }

        signInButton = BorderedButton(type: .system).then { button in

            button.setTitle("Sign in", for: .normal)

            button.onTap { [unowned self] _ in
                self.viewModel.userTappedRecovery()
            }

            addSubview(button) {
                $0.top.equalTo(loginField.snp.bottom).offset(UIForgotPasswordConstants.signInButtonOffset)
                $0.left.right.equalToSuperview().inset(35)
                $0.height.equalTo(50)
            }
        }

        _ = TappableButton(type: .system).then { button in

            button.setTitle("Login", for: .normal)
            button.setTitleColor(.primaryText, for: .normal)

            button.onTap { [unowned self] _ in
                self.coordinatorDelegate?.forgotPasswordViewControllerDidTapLogin(self)
            }

            addSubview(button) {
                $0.top.equalTo(signInButton.snp.bottom).offset(20)
                $0.centerX.equalTo(signInButton)
            }
        }
    }
}

extension ForgotPasswordViewController: ForgotPasswordViewModelDelegate {

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
        Alert.showOk(title: "Recover password",
                     message: "We have sent information about how to recover your account to your email",
                     show: self) { [unowned self] _ in

            self.coordinatorDelegate?.forgotPasswordViewControllerDidFinish(self)
        }
    }
}
