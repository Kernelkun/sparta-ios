//
//  UINavigationBar+Sizes.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit.UINavigationBar

extension UINavigationBar {

    var wholeHeight: CGFloat {
        frame.height + UIApplication.shared.statusBarFrame.height
    }
}
