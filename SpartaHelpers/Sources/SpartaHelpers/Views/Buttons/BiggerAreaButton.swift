//
//  BiggerAreaButton.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit

open class BiggerAreaButton: UIButton {

    @IBInspectable
    public var clickableInset: CGFloat = 0

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insetFrame = bounds.insetBy(dx: clickableInset, dy: clickableInset)
        return insetFrame.contains(point)
    }
}
