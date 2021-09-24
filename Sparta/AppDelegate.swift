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

extension Double {
    func round(nearest: Double, rule: FloatingPointRoundingRule) -> Double {
        let n = 1 / nearest
        let numberToRound = self * n
        return numberToRound.rounded(rule) / n
    }

    func round(nearest: Double) -> Double {
        let n = 1 / nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }

    func floor(nearest: Double) -> Double {
        let intDiv = Double(Int(self / nearest))
        return intDiv * nearest
    }
}

