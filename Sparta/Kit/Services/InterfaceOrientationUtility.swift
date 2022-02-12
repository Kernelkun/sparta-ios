//
//  InterfaceOrientationUtility.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.02.2022.
//

import UIKit

struct InterfaceOrientationUtility {

    static var interfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    static func lockOrientation(_ newOrientation: UIInterfaceOrientationMask, rotateTo orientation: UIInterfaceOrientation) {
        self.lockOrientation(newOrientation)
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}

