//
//  MainFlowCoordinator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

class MainFlowCoordinator: Coordinator {

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

        let vc = MainTabsViewController()
//        vc.coordinatorDelegate = self

        navigationController = UINavigationController(rootViewController: vc).then { navigationC in

            navigationC.interactivePopGestureRecognizer?.isEnabled = true
            navigationC.interactivePopGestureRecognizer?.delegate = self
            navigationC.delegate = self
            navigationC.isNavigationBarHidden = true
        }

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        // Flipping transition on switching from Auth to Content and back.
        UIView.transition(with: window, duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: nil, completion: { _ in
        })
    }

    override func finish() {
        guard isPresented else { return }
        super.finish()
    }
}

// navigation

extension MainFlowCoordinator: UINavigationControllerDelegate { }

extension MainFlowCoordinator: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
