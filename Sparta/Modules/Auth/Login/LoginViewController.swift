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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

    }

}
