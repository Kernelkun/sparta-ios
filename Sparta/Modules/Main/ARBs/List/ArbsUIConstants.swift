//
//  ArbsUIConstants.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.10.2021.
//

import UIKit
import NetworkingModels

enum ArbsUIConstants {

    static let listStackViewTopSpace: CGFloat = 10
    static let listStackViewElementSpace: CGFloat = 8
    static let listStackViewElementHeight: CGFloat = 15

    static let defaultCellHeight: CGFloat = 152

    static func cellHeight(for portfolio: Arb.Portfolio) -> CGFloat {
        if portfolio.isAra {
            return Self.defaultCellHeight
        } else {
            return 90
        }
    }
}
