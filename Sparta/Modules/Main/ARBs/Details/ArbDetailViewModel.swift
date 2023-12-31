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

protocol ArbDetailViewModelDelegate: AnyObject {
    func didChangeLoadingState(_ isLoading: Bool)
    func didCatchAnError(_ error: String)
    func didLoadCells(_ cells: [ArbDetailViewModel.Cell])
    func didReloadCells(_ cells: [ArbDetailViewModel.Cell])
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

    var userTarget: String? {
        selectedArbMonth.dbProperties.fetchUserTarget()?.toFormattedString
    }

    var monthPosition: ArbMonth.Position? {
        selectedArbMonth.position
    }

    // MARK: - Private properties

    private var selectedArbMonth: ArbMonth!
    private(set) var arb: Arb

    // MARK: - Initializers

    init(arb: Arb) {
        self.arb = arb
        super.init()

        observeArbs(arb)
    }

    deinit {
        stopObservingArbs(arb)
    }

    // MARK: - Public methods

    func loadData() {
        selectedArbMonth = arb.months[0]
        delegate?.didLoadCells(loadCellsForSelectedMonth())
    }

    func switchToPrevMonth() {
        guard arb.months.first != selectedArbMonth,
              let currentMonthIndex = arb.months.firstIndex(of: selectedArbMonth) else { return }

        let prevMonthIndex = arb.months.index(before: currentMonthIndex)

        selectedArbMonth = arb.months[prevMonthIndex]
        delegate?.didLoadCells(loadCellsForSelectedMonth())
    }

    func switchToNextMonth() {
        guard arb.months.last != selectedArbMonth,
              let currentMonthIndex = arb.months.firstIndex(of: selectedArbMonth) else { return }

        let nextMonthIndex = arb.months.index(after: currentMonthIndex)

        selectedArbMonth = arb.months[nextMonthIndex]
        delegate?.didLoadCells(loadCellsForSelectedMonth())
    }

    func switchToMonth(at index: Int) {
        guard arb.months.count > index else { return }

        selectedArbMonth = arb.months[index]
        delegate?.didLoadCells(loadCellsForSelectedMonth())
    }

    func applyUserTarget(_ userTarget: String) {
        if let userTarget = userTarget.nullable?.toDouble {
            selectedArbMonth.dbProperties.saveUserTarget(value: userTarget)
        } else {
            selectedArbMonth.dbProperties.deleteUserTarget()
        }
    }

    // MARK: - Private methods

    private func loadCellsForSelectedMonth() -> [Cell] {
        var cells: [ArbDetailViewModel.Cell] = [.emptySpace]

        let mainUnitValue = mainUnit(for: selectedArbMonth)
        let blendCostUnitValue = blendCostUnit(for: selectedArbMonth)
        let gasNapUnitValue = gasNapUnit(for: selectedArbMonth)
        let taArbUnitValue = taArbUnit(for: selectedArbMonth)
        let deliveredPriceUnitValue = deliveredPriceUnit(for: selectedArbMonth)

        cells.append(.status(position: monthPosition))

        cells.append(contentsOf: [.emptySpace, .target(value: userTarget, units: deliveredPriceUnitValue), .emptySpace])

        //blender cost

        cells.append(.blendCost(value: selectedArbMonth.blenderCost.value,
                                color: selectedArbMonth.blenderCost.valueColor,
                                units: blendCostUnitValue))

        // gas/naphta
//
//        cells.append(.gasNap(value: selectedArbMonth.gasMinusNaphtha.value,
//                             color: selectedArbMonth.gasMinusNaphtha.valueColor,
//                             units: gasNapUnitValue))

        // freight

        if let routeValue = selectedArbMonth.freight.routeType.displayRouteValue?.toDouble?.toFormattedString,
           let routeUnit = selectedArbMonth.freight.routeType.routeUnit {

            cells.append(.freight(value: routeValue,
                                  color: .gray,
                                  units: routeUnit))
        }

        // ta ARB

        if let taArb = selectedArbMonth.taArb {
            cells.append(
                .taArb(
                    value: taArb.value,
                    color: taArb.valueColor,
                    units: taArbUnitValue
                )
            )
        }

        if let ewArb = selectedArbMonth.ew {
            cells.append(.ew(value: ewArb.value, color: ewArb.valueColor, units: mainUnitValue))
        }

        cells.append(.emptySpace)

        // delivery price

        if let deliveredPrice = selectedArbMonth.deliveredPrice {
            cells.append(.dlvPrice(value: deliveredPrice.value.value,
                                   color: deliveredPrice.value.valueColor,
                                   units: deliveredPriceUnitValue)) // mainUnitValue
            cells.append(.dlvPriceBasis(value: deliveredPrice.basis, color: .gray))
            cells.append(.emptySpace)
        }

        // my margin

        cells.append(.myMargin(value: selectedArbMonth.calculatedUserMargin?.toDisplayFormattedString ?? "-",
                               color: selectedArbMonth.calculatedUserMargin?.color ?? .numberGray,
                               units: deliveredPriceUnitValue))

        // blender margin

        if let blenderMargin = selectedArbMonth.genericBlenderMargin {
            cells.append(.blenderMargin(
                value: blenderMargin.value,
                color: blenderMargin.valueColor,
                units: mainUnitValue
            ))
        }

        // pseudoFobRefinery

//        if let pseudoFobRefinery = selectedArbMonth.pseudoFobRefinery {
//            cells.append(.fobRefyMargin(value: pseudoFobRefinery.value,
//                                        color: pseudoFobRefinery.valueColor,
//                                        units: mainUnitValue))
//        }

        // pseudoCifRefinery

//        if let pseudoCifRefinery = selectedArbMonth.pseudoCifRefinery {
//            cells.append(.cifRefyMargin(value: pseudoCifRefinery.value,
//                                        color: pseudoCifRefinery.valueColor,
//                                        units: mainUnitValue))
//        }

        // blender margin CoD

        if let blenderMarginChangeOnDay = selectedArbMonth.genericBlenderMarginChangeOnDay {
            cells.append(.emptySpace)
            cells.append(.codBlenderMargin(value: blenderMarginChangeOnDay.value,
                                           color: blenderMarginChangeOnDay.valueColor,
                                           units: mainUnitValue))
        }

        return cells
    }

    // MARK: - Methods for calculating units

    private func mainUnit(for month: ArbMonth) -> String {
        if month.ew == nil && month.taArb == nil {
            return "$/mt"
        } else if month.ew != nil {
            return "$/bbl"
        } else if month.taArb != nil {
            return "cpg"
        }

        return ""
    }

    private func blendCostUnit(for month: ArbMonth) -> String {
        if arb.portfolio.isAra {
            return "$/mt"
        } else {
            return "cpg"
        }
    }

    private func gasNapUnit(for month: ArbMonth) -> String {
        "$/mt"
    }

    private func taArbUnit(for month: ArbMonth) -> String {
        "cpg"
    }

    private func deliveredPriceUnit(for month: ArbMonth) -> String {
        guard let deliveredPrice = selectedArbMonth.deliveredPrice else {
            return mainUnit(for: month)
        }

        return deliveredPrice.units
    }
}

extension ArbDetailViewModel: ArbsObserver {

    func arbsDidReceiveResponse(for arb: Arb) {
        guard let selectedMonth = selectedArbMonth else { return }

        onMainThread {
            self.arb = arb
            self.selectedArbMonth = arb.months.first(where: { $0.name == selectedMonth.name })

            self.delegate?.didReloadCells(self.loadCellsForSelectedMonth())
        }
    }
}
