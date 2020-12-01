//
//  UIColor+Assets.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import UIKit.UIColor

public extension UIColor {

    static var primaryText: UIColor { .assetColor(named: #function) }

    static var accountMainText: UIColor { .assetColor(named: #function) }

    static var secondaryText: UIColor { .assetColor(named: #function) }

    static var primaryFirst: UIColor { .assetColor(named: #function) }

    static var authFieldBackground: UIColor { .assetColor(named: #function) }

    static var accountFieldBackground: UIColor { .assetColor(named: #function) }

    static var mainButtonBackground: UIColor { .assetColor(named: #function) }

    static var mainBackground: UIColor { .assetColor(named: #function) }

    static var controlTintActive: UIColor { .assetColor(named: #function) }

    static var error: UIColor { .assetColor(named: #function) }

    static var errorBackground: UIColor { .assetColor(named: #function) }

    static var tableSeparator: UIColor { .assetColor(named: #function) }
}

private extension UIColor {

    static func assetColor(named name: String) -> UIColor {

        guard let retVal = UIColor(named: name) else {
            fatalError("Color named \(name) does not exist!")
        }

        return retVal
    }
}
