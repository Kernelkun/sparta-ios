//
//  UIStackView+Utilities.swift
//  
//
//  Created by Yaroslav Babalich on 06.10.2021.
//

import UIKit

extension UIStackView {

    public func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
