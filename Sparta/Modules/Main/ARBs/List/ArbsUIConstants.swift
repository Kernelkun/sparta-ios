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

    static func cellHeight(for arb: Arb) -> CGFloat {
        switch arb.presentationMonthsCount {
        case 6:
            return Self.defaultCellHeight

        case 4:
            return 105

        case 2:
            return 90

        default:
            return max(90, CGFloat(arb.presentationMonthsCount) * 25)
        }
    }
}
