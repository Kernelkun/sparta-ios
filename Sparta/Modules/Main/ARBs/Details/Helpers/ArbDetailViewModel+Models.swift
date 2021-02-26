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
        case target(value: String?, units: String)
        case blendCost(value: String, color: UIColor, units: String)
        case gasNap(value: String, color: UIColor, units: String)
        case freight(value: String, color: UIColor, units: String)
        case taArb(value: String, color: UIColor, units: String)
        case ew(value: String, color: UIColor, units: String)
        case dlvPrice(value: String, color: UIColor, units: String)
        case dlvPriceBasis(value: String, color: UIColor)
        case myMargin(value: String, color: UIColor, units: String)
        case blenderMargin(value: String, color: UIColor, units: String)
        case fobRefyMargin(value: String, color: UIColor, units: String)
        case cifRefyMargin(value: String, color: UIColor, units: String)
        case codBlenderMargin(value: String, color: UIColor, units: String)
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
                return "E/W"

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
