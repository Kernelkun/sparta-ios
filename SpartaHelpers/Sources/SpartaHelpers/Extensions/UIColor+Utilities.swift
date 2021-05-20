//
//  UIColor+Utilities.swift
//  
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

public extension UIColor {

    static func assetColor(named name: String) -> UIColor {
        guard let retVal = UIColor(named: name) else {
            fatalError("Color named \(name) does not exist!")
        }

        return retVal
    }

    convenience init(from red: Int, green: Int, blue: Int, alpha: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    convenience init(hex: Int) {
        self.init(from: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff, alpha: 1.0)
    }

    convenience init(hex: Int, alpha: CGFloat) {
        self.init(from: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff, alpha: alpha)
    }
}
