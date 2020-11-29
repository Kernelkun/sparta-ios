//
//  UIFont+Sparta.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.11.2020.
//

import UIKit

extension UIFont {

    static func main(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        return UIFont(name: Self.fontName(from: weight), size: size)! //swiftlint:disable:this force_unwrapping
    }

    private static func fontName(from weight: UIFont.Weight) -> String {
        switch weight {
        case .semibold: return "OpenSans-SemiBold"
        case .lightItalic: return "OpenSans-LightItalic"
        default: return "OpenSans-Regular"
        }
    }
}

extension UIFont.Weight {

    static var lightItalic: UIFont.Weight {
        return UIFont.Weight(rawValue: -1)
    }
}
