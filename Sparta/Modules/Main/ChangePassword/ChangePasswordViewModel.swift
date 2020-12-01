//
//  ChangePasswordViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2020.
//

import Foundation
import Networking

protocol ChangePasswordViewModelDelegate: class {
    func didChangeSendingState(_ isSending: Bool)
    func cleanupInputErrors()
    func didCatchAnError(_ description: String)
    func didFinishSuccess()
}

class ChangePasswordViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ChangePasswordViewModelDelegate?

    var oldPasswordText: String?
    var newPasswordText: String?
    var reNewPasswordText: String?

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
    private let profileManager = ProfileNetworkManager()

    // MARK: - Private methods

    private func changePassword(oldPassword: String, newPassword: String) {

        let currentUser = App.instance.currentUser

        guard let login = currentUser?.email, let userId = currentUser?.id else {
            delegate?.didCatchAnError("Something went wrong. Please re-login to the app.")
            return
        }

        authManager.auth(login: login, password: oldPassword) { [weak self] result in
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

                App.instance.saveLoginData(model)

                strongSelf.updateUser(id: userId, password: newPassword)

            case .failure(let error):

                var errorText = "Something went wrong"

                if error == .error400 {
                    errorText = "Old password is incorrect, please enter new one"
                }

                onMainThread {
                    strongSelf.isSending = false
                    strongSelf.delegate?.didCatchAnError(errorText)
                }
            }
        }
    }

    private func updateUser(id: Int, password: String) {

        let updateParameters: Parameters = [
            "password": password,
            "confirmed": true
        ]

        profileManager.updateUser(id: id, parameters: updateParameters) { [weak self] result in
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

                App.instance.saveUser(model)

                onMainThread {
                    strongSelf.isSending = false
                    strongSelf.delegate?.didFinishSuccess()
                }

            case .failure(let error):

                var errorText = "Something went wrong"

                if error == .error400 {
                    errorText = "Old password is incorrect, please enter new one"
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

extension ChangePasswordViewModel {

    func userTappedChangePassword() {

        let passwordString = oldPasswordText?.trimmed.nullable
        let newPasswordString = newPasswordText?.trimmed.nullable
        let reNewPasswordString = reNewPasswordText?.trimmed.nullable

        let passwordValidator = PasswordValidator()

        // check old password

        guard passwordValidator.isValid(value: passwordString) else {
            delegate?.didCatchAnError(
                passwordValidator.errorMessage ?? ""
            )
            return
        }

        // check new password

        guard passwordValidator.isValidForSetup(value: newPasswordString) else {
            delegate?.didCatchAnError(
                passwordValidator.errorMessage ?? ""
            )
            return
        }

        // check re-new password

        guard passwordValidator.isValidForSetup(value: reNewPasswordString) else {
            delegate?.didCatchAnError(
                passwordValidator.errorMessage ?? ""
            )
            return
        }

        // check both passwords

        guard newPasswordString == reNewPasswordString  else {
            delegate?.didCatchAnError(
                "Passwords is not equal. Please enter again."
            )
            return
        }

        guard isSending == false else { return }

        isSending = true

        changePassword(oldPassword: oldPasswordText!, newPassword: newPasswordText!) //swiftlint:disable:this force_unwrapping
    }
}
