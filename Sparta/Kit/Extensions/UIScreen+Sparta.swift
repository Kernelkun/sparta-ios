//
//  UIScreen+Sparta.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.11.2020.
//

import UIKit

extension UIScreen {

    class var isSmallDevice: Bool {
        return UIScreen.main.bounds.height <= 667
    }
}
