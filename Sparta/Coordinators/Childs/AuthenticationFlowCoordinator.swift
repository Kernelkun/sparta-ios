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

        UIView.animate(
            withDuration: 0.2, delay: 0,
            options: [.beginFromCurrentState],
            animations: {
            },
            completion: { _ in if !self.isPresented { self.window.isHidden = true } }
        )
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
        appCoordinator.start()
    }
}
