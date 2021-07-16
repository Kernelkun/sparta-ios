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
                return "ArbDetailPage.Key.Status.Title".localized

            case .target:
                return "ArbDetailPage.Key.Target.Title".localized

            case .blendCost:
                return "ArbDetailPage.Key.BlendCost.Title".localized

            case .gasNap:
                return "ArbDetailPage.Key.GasNap.Title".localized

            case .freight:
                return "ArbDetailPage.Key.Freight.Title".localized

            case .taArb:
                return "ArbDetailPage.Key.TaArb.Title".localized

            case .ew:
                return "ArbDetailPage.Key.Ew.Title".localized

            case .dlvPrice:
                return "ArbDetailPage.Key.DlvPrice.Title".localized

            case .dlvPriceBasis:
                return "ArbDetailPage.Key.DlvPriceBasis.Title".localized

            case .myMargin:
                return "ArbDetailPage.Key.MyMargin.Title".localized

            case .blenderMargin:
                return "ArbDetailPage.Key.BlenderMargin.Title".localized

            case .fobRefyMargin:
                return "ArbDetailPage.Key.FobRefyMargin.Title".localized

            case .cifRefyMargin:
                return "ArbDetailPage.Key.CifRefyMargin.Title".localized

            case .codBlenderMargin:
                return "ArbDetailPage.Key.CodBlenderMargin.Title".localized

            case .emptySpace:
                return ""
            }
        }
    }
}
