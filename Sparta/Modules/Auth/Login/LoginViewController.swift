//
//  LoginViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.11.2020.
//

import UIKit

protocol LoginViewCoordinatorDelegate: class {

}

class LoginViewController: BaseVMViewController<LoginViewModel> {

    // MARK: - Public properties

    weak var coordinatorDelegate: LoginViewCoordinatorDelegate?

    // MARK: - Private properties

    private var loginField: RoundedTextField!
    private var passwordField: RoundedTextField!
    private var logoView: AvatarView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
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
                $0.top.equalToSuperview().offset(topBarHeight + 38)
                $0.centerX.equalToSuperview()
            }
        }

        loginField = RoundedTextField().then { field in

            field.icon = UIImage(named: "ic_field_user")
            field.placeholder = "Email"

            addSubview(field) {
                $0.top.equalTo(logoView.snp.bottom).offset(80)
                $0.left.right.equalToSuperview().inset(35)
                $0.height.equalTo(48)
            }
        }

        passwordField = RoundedTextField().then { field in

            field.icon = UIImage(named: "ic_field_lock")
            field.placeholder = "Password"
            field.textField.isSecureTextEntry = true

            addSubview(field) {
                $0.top.equalTo(loginField.snp.bottom).offset(21)
                $0.left.right.equalToSuperview().inset(35)
                $0.height.equalTo(48)
            }
        }
    }
}
