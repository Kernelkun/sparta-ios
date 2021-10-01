//
//  AppCoordinator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit
import SpartaHelpers

class AppCoordinator {

    //
    // MARK: - Public Stuff

    var isPresentedMainFlow: Bool {
        return mainFlowCoordinator.isPresented
    }

    let contentWindow: UIWindow

    //
    // MARK: - Private Stuff

    private let blurCoordinator: BlurCoordinator
    private let authenticationFlowCoordinator: AuthenticationFlowCoordinator
    private let mainFlowCoordinator: MainFlowCoordinator

    //
    // MARK: - Object Lifecycle

    init() {

        defer {
            authenticationFlowCoordinator.delegate = self
            mainFlowCoordinator.delegate = self
            App.instance.delegate = self
        }

        do {
            contentWindow = UIWindow(frame: UIScreen.main.bounds)
            contentWindow.windowLevel = .normal
            if #available(iOS 13.0, *) {
                contentWindow.overrideUserInterfaceStyle = .dark
            }

            mainFlowCoordinator = MainFlowCoordinator(window: contentWindow)
            authenticationFlowCoordinator = AuthenticationFlowCoordinator(window: contentWindow)
        }

        do {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.windowLevel = .init(UIWindow.Level.normal.rawValue + 1)
            window.backgroundColor = .clear
            if #available(iOS 13.0, *) {
                window.overrideUserInterfaceStyle = .dark
            }

            blurCoordinator = BlurCoordinator(window: window)
        }

        // UI

        setupAppearances()

        // logic

        setupLogic()
    }

    // MARK: - Public methods

    func start() {

        let app = App.instance

        guard app.isSignedIn else {
            blurCoordinator.finish(forced: true)
            authenticationFlowCoordinator.start()
            authenticationFlowCoordinator.proceedToLogin()
            return
        }

        guard app.isInitialDataSynced else {
            blurCoordinator.start(forced: true, status: "BlurPage.Loading.Title".localized)
            app.syncInitialData()
            return
        }

        app.appDidMakeAuthentication()

        blurCoordinator.finish(forced: true)
        mainFlowCoordinator.start()
    }

    func showLoading(text: String) {
        onMainThread {
            self.blurCoordinator.start(forced: true, status: text)
        }
    }

    func hideLoading() {
        onMainThread {
            self.blurCoordinator.finish(forced: true)
        }
    }

    // MARK: - Private methods

    private func setupAppearances() {
        // navigation bar
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                                                              .foregroundColor: UIColor.primaryText]

        UINavigationBar.appearance().titleTextAttributes = titleAttributes

        let backImage = UIImage(named: "ic_back")?
            .withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -24, bottom: 0, right: 0))

        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UINavigationBar.appearance().tintColor = .controlTintActive

        let standard = UINavigationBarAppearance()

        standard.configureWithTransparentBackground()
        standard.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

        let button = UIBarButtonItemAppearance(style: .plain)
        button.normal.titleTextAttributes = [.foregroundColor: UIColor.controlTintActive]
        standard.buttonAppearance = button

        standard.titleTextAttributes = titleAttributes

        UINavigationBar.appearance().standardAppearance = standard
    }

    private func setupLogic() {

        // analytics

        AnalyticsManager.intance.start()

        // logout if needed

        if UserDefaults.isFirstLaunch {
            App.instance.logout()
        }
    }
}

extension AppCoordinator: CoordinatorDelegate {

    func coordinatorDidStart(_ coordinator: Coordinator) {

        //

        switch coordinator {
        case authenticationFlowCoordinator:
            mainFlowCoordinator.finish()
            blurCoordinator.finish()

        case mainFlowCoordinator:
            authenticationFlowCoordinator.finish()
            blurCoordinator.finish()

        default:
            fatalError("Should not ever happen!")
        }
    }

    func coordinatorDidFinish(_ coordinator: Coordinator) {
    }
}

extension AppCoordinator: AppFlowDelegate {

    func appFlowDidUpdate() {
        onMainThread {
            self.start()
        }
    }
}
