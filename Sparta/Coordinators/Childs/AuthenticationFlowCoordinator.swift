//
//  AuthenticationFlowCoordinator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit
import Then

class AuthenticationFlowCoordinator: Coordinator {

    // MARK: - Variables private

    private let window: UIWindow
    private var navigationController: UINavigationController?

    // MARK: - Initializer

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Public methods

    override func start() {

        guard !isPresented else { return }
        super.start()

        //

        setupNavigationControllerIfNeeded(rootViewController: LaunchViewController())

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        // Flipping transition on switching from Auth to Content and back.
        UIView.transition(with: window, duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: nil, completion: nil
        )
    }

    override func finish() {
        guard isPresented else { return }
        super.finish()
    }

    // MARK: - Private methods

    private func setupNavigationControllerIfNeeded(rootViewController: UIViewController) {
        guard navigationController == nil else { return }

        navigationController = UINavigationController(rootViewController: rootViewController).then { nc in

//            Router.instance.navigationViewController = nc

            nc.interactivePopGestureRecognizer?.isEnabled = true
            nc.isNavigationBarHidden = true
        }
    }
}

extension AuthenticationFlowCoordinator {

    func proceedToLogin() {

        guard
            let rootVC = window.rootViewController as? UINavigationController
        else { return }

        onMainThread(delay: 0.4) {

            let loginVC = LoginViewController()
            loginVC.coordinatorDelegate = self

            rootVC.viewControllers = [loginVC]
        }
    }
}

extension AuthenticationFlowCoordinator: LoginViewCoordinatorDelegate {

    func loginViewControllerDidFinish(_ controller: LoginViewController) {
        guard App.instance.isAccountConfirmed else {

            let vc = ChangePasswordViewController()
            vc.coordinatorDelegate = self

            navigationController?.pushViewController(vc, animated: true)
            return
        }

        appCoordinator.start()
    }

    func loginViewControllerDidChooseForgotPassword(_ controller: LoginViewController) {
        let vc = ForgotPasswordViewController()
        vc.coordinatorDelegate = self

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AuthenticationFlowCoordinator: ForgotPasswordViewCoordinatorDelegate {

    func forgotPasswordViewControllerDidFinish(_ controller: ForgotPasswordViewController) {
        navigationController?.popViewController(animated: true)
    }

    func forgotPasswordViewControllerDidTapLogin(_ controller: ForgotPasswordViewController) {
        navigationController?.popViewController(animated: true)
    }
}

extension AuthenticationFlowCoordinator: ChangePasswordViewCoordinatorDelegate {

    func changePasswordViewControllerDidFinish(_ controller: ChangePasswordViewController) {
        appCoordinator.start()
    }
}
