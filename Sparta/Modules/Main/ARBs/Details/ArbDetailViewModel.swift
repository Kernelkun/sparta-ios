//
//  ArbDetailViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol ArbDetailViewModelDelegate: class {
    func didChangeLoadingState(_ isLoading: Bool)
    func didCatchAnError(_ error: String)
    func didLoadData()
}

class ArbDetailViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbDetailViewModelDelegate?

    var cells: [Cell] = []

    var ableToSwitchPrevMonth: Bool {
        arb.months.first != selectedArbMonth
    }

    var ableToSwitchNextMonth: Bool {
        arb.months.last != selectedArbMonth
    }

    var formattedMonthTitle: String {
        selectedArbMonth.name
    }

    // MARK: - Private properties

    private var selectedArbMonth: ArbMonth! {
        didSet {
            loadCellsForSelectedMonth()
        }
    }
    private let arb: Arb

    // MARK: - Initializers

    init(arb: Arb) {
        self.arb = arb
        super.init()
    }

    // MARK: - Public methods

    func loadData() {
        selectedArbMonth = arb.months[0]
    }

    func switchToPrevMonth() {
        guard arb.months.first != selectedArbMonth,
              let currentMonthIndex = arb.months.firstIndex(of: selectedArbMonth) else { return }

        let prevMonthIndex = arb.months.index(before: currentMonthIndex)

        selectedArbMonth = arb.months[prevMonthIndex]
    }

    func switchToNextMonth() {
        guard arb.months.last != selectedArbMonth,
              let currentMonthIndex = arb.months.firstIndex(of: selectedArbMonth) else { return }

        let nextMonthIndex = arb.months.index(after: currentMonthIndex)

        selectedArbMonth = arb.months[nextMonthIndex]
    }

    // MARK: - Private methods

    private func loadCellsForSelectedMonth() {
        cells = [.emptySpace, .emptySpace, .target, .emptySpace]

        //blender cost

        cells.append(.blendCost(value: selectedArbMonth.blenderCost.value, color: selectedArbMonth.blenderCost.valueColor))

        // gas/naphta

        cells.append(.gasNap(value: selectedArbMonth.gasMinusNaphtha.value, color: selectedArbMonth.gasMinusNaphtha.valueColor))

        // freight

        cells.append(.freight(value: selectedArbMonth.freight.freightRate.toFormattedString, color: .gray))

        // ta ARB

        if let taArb = selectedArbMonth.taArb {
            cells.append(.taArb(value: taArb.value, color: taArb.valueColor))
        }

        cells.append(.emptySpace)

        // delivery price

        cells.append(.dlvPrice(value: selectedArbMonth.deliveredPrice.value.value,
                               color: selectedArbMonth.deliveredPrice.value.valueColor))
        cells.append(.dlvPriceBasis(value: selectedArbMonth.deliveredPrice.basis, color: .gray))

        cells.append(.emptySpace)

        // my margin

        cells.append(.myMargin(value: "0.0", color: .gray))

        // blender margin

        if let blenderMargin = selectedArbMonth.genericBlenderMargin {
            cells.append(.blenderMargin(value: blenderMargin.value, color: blenderMargin.valueColor))
        }

        // blender margin CoD

        if let blenderMarginChangeOnDay = selectedArbMonth.genericBlenderMarginChangeOnDay {
            cells.append(.codBlenderMargin(value: blenderMarginChangeOnDay.value, color: blenderMarginChangeOnDay.valueColor))
        }

        // pseudoFobRefinery

        if let pseudoFobRefinery = selectedArbMonth.pseudoFobRefinery {
            cells.append(.fobRefyMargin(value: pseudoFobRefinery.value, color: pseudoFobRefinery.valueColor))
        }

        // pseudoFobRefinery

        if let pseudoCifRefinery = selectedArbMonth.pseudoCifRefinery {
            cells.append(.cifRefyMargin(value: pseudoCifRefinery.value, color: pseudoCifRefinery.valueColor))
        }

        // 

        delegate?.didLoadData()
    }
}

extension ArbDetailViewModel {

    enum Cell {
        case target
        case blendCost(value: String, color: UIColor)
        case gasNap(value: String, color: UIColor)
        case freight(value: String, color: UIColor)
        case taArb(value: String, color: UIColor)
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
