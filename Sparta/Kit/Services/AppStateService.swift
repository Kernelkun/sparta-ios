//
//  AppStateService.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.12.2020.
//

import UIKit.UIApplication

protocol AppStateServiceDelegate: AnyObject {
    func appStateServiceDidUpdateState()
}

class AppStateService {

    // MARK: - Public variables

    weak var delegate: AppStateServiceDelegate?

    private(set) var isActiveApp: Bool = true {
        didSet {
            onMainThread {
                self.delegate?.appStateServiceDidUpdateState()
            }
        }
    }

    // MARK: - Initiliazers

    init() {
        subsribeToApplicationStateEvents()
    }

    deinit {
        unsubscribeFromApplicationStates()
    }

    // MARK: - Private methods

    private func subsribeToApplicationStateEvents() {

        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationWillEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationWillEnterForeground(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func unsubscribeFromApplicationStates() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private methods

    //

    @objc
    private func applicationDidEnterBackground(_ notification: Notification) {
        isActiveApp = false
    }

    @objc
    private func applicationWillEnterForeground(_ notification: Notification) {
        isActiveApp = true
    }
}
