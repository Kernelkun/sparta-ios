//
//  AppDelegate.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.11.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // launch settings

        if let launchCount = UserDefaults.int(forKey: .launchCount) {
            UserDefaults.set(launchCount + 1, forKey: .launchCount)
        } else {
            UserDefaults.set(1, forKey: .launchCount)
        }

        // coordinator

        appCoordinator = AppCoordinator()
        appCoordinator.start()

        return true
    }
}
