//
//  LoginViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.11.2020.
//

import Foundation
import Networking

protocol LoginViewModelDelegate: class {
    func didChangeSendingState(_ isSending: Bool)
    func cleanupInputErrors()
    func didCatchAnError(_ description: String)
    func didFinishSuccess()
}

class LoginViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LoginViewModelDelegate?

    var loginText: String?
    var passwordText: String?

    //
    // MARK: - Private properties

    private var isSending: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeSendingState(self.isSending)
            }
        }
    }

    private let authManager = AuthNetworkManager()

    // MARK: - Private methods

    private func auth(login: String, password: String) {
        authManager.auth(login: login, password: password) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let response):

                guard let model = response.model else {
                    onMainThread {
                        strongSelf.isSending = false
                        strongSelf.delegate?.didCatchAnError("Can't parse response from server")
                    }
                    return
                }

                App.instance.saveTokenData(model.jwt)

                onMainThread {
                    strongSelf.isSending = false
                    strongSelf.delegate?.didFinishSuccess()
                }

            case .failure(let error):

                var errorText = "Something went wrong"

                if error == .error400 {
                    errorText = "Invalid creds, please enter new one"
                }

                onMainThread {
                    strongSelf.isSending = false
                    strongSelf.delegate?.didCatchAnError(errorText)
                }
            }
        }
    }
}

//
// MARK: - User Interactions

extension LoginViewModel {

    func userTappedLogin() {

        let emailString = loginText?.trimmed.nullable
        let passwordString = passwordText?.trimmed.nullable

        let emailUsernameValidator = EmailValidator()
        guard emailUsernameValidator.isValid(value: emailString) else {
            delegate?.didCatchAnError(
                emailUsernameValidator.errorMessage ?? ""
            )
            return
        }

        let passwordValidator = PasswordValidator()
        guard passwordValidator.isValid(value: passwordString) else {
            delegate?.didCatchAnError(
                passwordValidator.errorMessage ?? ""
            )
            return
        }

        guard isSending == false else { return }

        isSending = true

        auth(login: emailString!, password: passwordString!)
    }
}

