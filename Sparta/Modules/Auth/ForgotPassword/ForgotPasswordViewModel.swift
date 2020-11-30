//
//  ForgotPasswordViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation
import Networking

protocol ForgotPasswordViewModelDelegate: class {
    func didChangeSendingState(_ isSending: Bool)
    func cleanupInputErrors()
    func didCatchAnError(_ description: String)
    func didFinishSuccess()
}

class ForgotPasswordViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ForgotPasswordViewModelDelegate?

    var loginText: String?

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

    private func recovery(email: String) {
        authManager.forgotPassword(for: email) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let response):

                guard response.model != nil else {
                    onMainThread {
                        strongSelf.isSending = false
                        strongSelf.delegate?.didCatchAnError("Can't parse response from server")
                    }
                    return
                }

                onMainThread {
                    strongSelf.isSending = false
                    strongSelf.delegate?.didFinishSuccess()
                }

            case .failure(let error):

                var errorText = "Something went wrong"

                if error == .error400 {
                    errorText = "User with this email doesn't exist"
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

extension ForgotPasswordViewModel {

    func userTappedRecovery() {

        let emailString = loginText?.trimmed.nullable

        let emailUsernameValidator = EmailValidator()
        guard emailUsernameValidator.isValid(value: emailString) else {
            delegate?.didCatchAnError(
                emailUsernameValidator.errorMessage ?? ""
            )
            return
        }

        guard isSending == false else { return }

        isSending = true

        recovery(email: emailString!) //swiftlint:disable:this force_unwrapping
    }
}
