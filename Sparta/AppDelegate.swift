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


        // test code

        func roundValue(_ value: Double) -> Double {
            let denominator: Double = 4
            return round(value * denominator) / denominator
        }

        print("Old function")
        print(roundValue(1.11))
        print(roundValue(1.18))
        print(roundValue(22.45))


        print("New function")
        print(1.11.round(nearest: 0.25).toFormattedString)
        print(1.18.round(nearest: 0.25).toFormattedString)
        print(22.41.round(nearest: 0.05).toFormattedString)

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

