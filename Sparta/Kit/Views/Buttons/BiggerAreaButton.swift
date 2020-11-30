//
//  BiggerAreaButton.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

class BiggerAreaButton: UIButton {

    @IBInspectable var clickableInset: CGFloat = 0

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insetFrame = bounds.insetBy(dx: clickableInset, dy: clickableInset)
        return insetFrame.contains(point)
    }
}
