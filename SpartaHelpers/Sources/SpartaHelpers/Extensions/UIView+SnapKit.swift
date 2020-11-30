//
//  UIView+SnapKit.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import UIKit
import SnapKit

public extension UIView {

    func addSubview(_ subview: UIView, makeConstraints: (ConstraintMaker) -> Void) {
        addSubview(subview)
        subview.snp.makeConstraints { makeConstraints($0) }
    }
}

public extension UIViewController {

    func addSubview(_ subview: UIView, makeConstraints: (ConstraintMaker) -> Void) {
        view.addSubview(subview)
        subview.snp.makeConstraints { makeConstraints($0) }
    }
}

public extension CGFloat {

    static var separatorWidth: Self {
        switch UIScreen.main.scale {
        case 3: return 2 / UIScreen.main.scale
        default: return 1 / UIScreen.main.scale
        }
    }
}
