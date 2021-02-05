//
//  ArbDetailViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.01.2021.
//

import UIKit
import NetworkingModels

extension ArbDetailViewModel {

    enum Cell {
        case status(position: ArbMonth.Position?)
        case target(value: String?)
        case blendCost(value: String, color: UIColor)
        case gasNap(value: String, color: UIColor)
        case freight(value: String, color: UIColor)
        case taArb(value: String, color: UIColor)
        case ew(value: String, color: UIColor)
        case dlvPrice(value: String, color: UIColor)
        case dlvPriceBasis(value: String, color: UIColor)
        case myMargin(value: String, color: UIColor)
        case blenderMargin(value: String, color: UIColor)
        case fobRefyMargin(value: String, color: UIColor)
        case cifRefyMargin(value: String, color: UIColor)
        case codBlenderMargin(value: String, color: UIColor)
        case emptySpace

        var displayTitle: String {
            switch self {
            case .status:
                return "Arb Open/Close"

            case .target:
                return "My Target"

            case .blendCost:
                return "Blend Cost"

            case .gasNap:
                return "Gas/Nap"

            case .freight:
                return "Freight"

            case .taArb:
                return "TA Arb"

            case .ew:
                return "E/W Arb"

            case .dlvPrice:
                return "Dlv Price"

            case .dlvPriceBasis:
                return "Dlv Price Basis"

            case .myMargin:
                return "My Margin"

            case .blenderMargin:
                return "Blender Margin"

            case .fobRefyMargin:
                return "FOB Refy Margin"

            case .cifRefyMargin:
                return "CIF Refy Margin"

            case .codBlenderMargin:
                return "CoD Blender Margin"

            case .emptySpace:
                return ""
            }
        }
    }
}
