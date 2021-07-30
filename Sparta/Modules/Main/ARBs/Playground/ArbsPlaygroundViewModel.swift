//
//  ArbsPlaygroundViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.07.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol ArbsPlaygroundViewModelDelegate: AnyObject {
    func didChangeLoadingState(_ isLoading: Bool)
    func didCatchAnError(_ error: String)
}

class ArbsPlaygroundViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbsPlaygroundViewModelDelegate?

    // MARK: - Private properties

    private let arbsManager = ArbsNetworkManager()
    private var arbs: [Arb] = []

    // MARK: - Public methods

    func loadData() {
        arbsManager.fetchArbsTable { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let arbs = responseModel.model?.list {

                strongSelf.arbs = arbs

                // test code

                strongSelf.arbsManager.fetchArbPlayground(for: strongSelf.arbs[2]) { result in

                    if case let .success(responseModel) = result,
                       let arbPlaygound = responseModel.model {

                        strongSelf.calculate(for: arbPlaygound)
                    }
                }

                // end of test code
            }
        }
    }

    private func calculate(for arbPlayground: ArbPlayground) {
        print("DEBUG ***: Result of calculations")

        let arb = arbs[2]
        let month = arbPlayground.months[1]
        let deliveredPriceSpreadsMonth = arbPlayground.deliveredPriceSpreads[0]

        let blendCost = month.blendCost
        let blendCostValue = (blendCost.value ?? 0.0).round(to: 2)
        print("Blend Cost: \(blendCostValue), unit: \(blendCost.units)")

        let gasNaphtha = month.naphtha
        print("Gas Nap: \(gasNaphtha.value), pricingComponentsVolume: \(gasNaphtha.pricingComponentsVolume)")

        let costs = month.costs
        let costsValue = (month.costs.value ?? 0.0).round(to: 2)
        print("Costs: \(costsValue), unit: \(costs.units)")

        print("Dlv price basis: \(deliveredPriceSpreadsMonth.name)")

        print("------")

        print("Delivered Price: \(deliveredPriceSpreadsMonth.value)")

        // rate
        let loadedQuantity = month.loadedQuantity.value ?? 0.0
        let freightRate = calculateRate(for: arb, loadedQuantity: loadedQuantity)

        // priceBeforeTAEW

        let priceBeforeTAEW = blendCostValue + freightRate + costsValue

        // default calculations

        let defaultCalculationSum = getDefaultCalculation(month: month,
                                                          spreadMonths: arbPlayground.deliveredPriceSpreads,
                                                          gradeCode: deliveredPriceSpreadsMonth.name)

        // foundDlvdMonthName

        let foundDlvdMonthName = arbPlayground.deliveredPriceSpreads.first(where: { $0.monthName == month.defaultSpreadMonthName })! // test code

        // getSpreadSumForMonths

        let spreadToSumDefault = getSpreadSumForMonths(month: month,
                                                       dlvdPriceBasisMonth: foundDlvdMonthName,
                                                       spreadMonths: arbPlayground.deliveredPriceSpreads)

        let foundDlvdFromLabel = arbPlayground.deliveredPriceSpreads.first(where: { $0.monthName == "Aug 21" })!

        let spreadToSum = getSpreadSumForMonths(month: month, dlvdPriceBasisMonth: foundDlvdFromLabel, spreadMonths: arbPlayground.deliveredPriceSpreads)

        var deliveredPriceDefault = priceBeforeTAEW
        var deliveredPrice = priceBeforeTAEW
        var units = "$/mt"
        var divider = 0.25

        //        var taArb: Double? = 100

        if let taArb = month.taArb.value { // or user can input it manually
            deliveredPriceDefault = priceBeforeTAEW / 3.5 - taArb + defaultCalculationSum
            deliveredPrice = priceBeforeTAEW / 3.5 - taArb + defaultCalculationSum
            units = "cpg"
            divider = 0.05
        } else if let ew = month.ew.value {
            deliveredPriceDefault = priceBeforeTAEW / 8.33 - ew + defaultCalculationSum
            deliveredPrice = priceBeforeTAEW / 8.33 - ew + defaultCalculationSum;
            units = "$/bbl"
            divider = 0.05
        } else {
            deliveredPriceDefault = priceBeforeTAEW + defaultCalculationSum
            deliveredPrice = priceBeforeTAEW + defaultCalculationSum
        }

        deliveredPriceDefault += spreadToSumDefault
        deliveredPrice += spreadToSum

        let blenderMargin = (month.salesPrice.value ?? 0.0) - deliveredPriceDefault
        let fobRefyMargin = blenderMargin + Double(arbPlayground.pseudoRefineryFobValue)
        let cifRefyMargin = blenderMargin + Double(arbPlayground.pseudoRefineryCifValue)
        let userTargetMargin = "-" /*Number.isNaN(parseFloat(userTarget)) ? '-' : parseFloat(userTarget) - deliveredPriceDefault;*/


        print("Results -------:")

        print("Delivered Price: \(deliveredPrice)  \(units)")
        print("Blender Margin: \(blenderMargin)  \(units)")
        print("FobRefyMargin: \(fobRefyMargin)  \(units)")
        print("CifRefyMargin: \(cifRefyMargin)  \(units)")
        print("My TGT Margin: \(userTargetMargin)  \(units)")
    }

    private func calculateRate(for arb: Arb, loadedQuantity: Double) -> Double {
        let vessel = arb.freight.vessel
        let lumpsum: Double

        if vessel.routeType.lowercased() == "LS".lowercased() {
            lumpsum = vessel.routeTypeValue
        } else {
            let wsInPercentage = vessel.routeTypeValue / 100

            if loadedQuantity <= vessel.cpBasis {
                lumpsum = vessel.cpBasis * vessel.flatRate * wsInPercentage
            } else {
                let firstCondition = loadedQuantity - vessel.cpBasis
                lumpsum = vessel.cpBasis * vessel.flatRate * wsInPercentage + firstCondition * vessel.flatRate * wsInPercentage * vessel.overage
            }
        }

        guard lumpsum != 0 && loadedQuantity != 0 else {
            return 0
        }

        return lumpsum / loadedQuantity
    }

    private func getDefaultCalculation(month: ArbPlaygroundMonth, spreadMonths: [ArbPlaygroundDPS], gradeCode: String) -> Double {
        if month.monthName == month.arrivalMonthName {
            return 0
        }

        if gradeCode.lowercased() == "rbob" {
            return spreadMonths.first(where: { $0.monthName == month.arrivalMonthName })?.value ?? 0.0
        }

        if let monthIndex = spreadMonths.firstIndex(where: { $0.monthName == month.monthName }),
           let defaultSpreadMonthIndex = spreadMonths.firstIndex(where: { $0.monthName == month.defaultSpreadMonthName }) {

            return spreadMonths[monthIndex...defaultSpreadMonthIndex].compactMap { $0.value }.reduce(0, +)
        } else {
            return 0
        }
    }

    private func getSpreadSumForMonths(month: ArbPlaygroundMonth, dlvdPriceBasisMonth: ArbPlaygroundDPS, spreadMonths: [ArbPlaygroundDPS]) -> Double {
        /// Enter data

        //        month, dlvdPriceBasisMonth, spreadMonths

        //        if (month && dlvdPriceBasisMonth && month.defaultSpreadMonthName === dlvdPriceBasisMonth.monthName) {
        //            return 0;
        //          }
        //
        //          const defaultDlvdPriceMonthIndex = spreadMonths.findIndex(
        //            (dpbmo) => dpbmo.monthName === month.defaultSpreadMonthName,
        //          );
        //          const selectedDlvdPriceMonthIndex = spreadMonths.findIndex(
        //            (dpbmo) => dpbmo.monthName === dlvdPriceBasisMonth.monthName,
        //          );
        //
        //          if (selectedDlvdPriceMonthIndex < defaultDlvdPriceMonthIndex) {
        //            return spreadMonths[selectedDlvdPriceMonthIndex].value * -1;
        //          }
        //
        //          return spreadMonths
        //            .slice(defaultDlvdPriceMonthIndex, selectedDlvdPriceMonthIndex)
        //            .reduce((acc, dpbmo) => acc + dpbmo.value, 0);


        guard dlvdPriceBasisMonth.monthName != month.defaultSpreadMonthName else {
            return 0
        }

        guard let defaultDlvdPriceMonthIndex = spreadMonths.firstIndex(where: { $0.monthName == month.defaultSpreadMonthName }),
              let selectedDlvdPriceMonthIndex = spreadMonths.firstIndex(where: { $0.monthName == dlvdPriceBasisMonth.monthName })
        else {
            return 0
        }

        if selectedDlvdPriceMonthIndex < defaultDlvdPriceMonthIndex {
            return spreadMonths[selectedDlvdPriceMonthIndex].value * -1;
        }

        return 0
    }
}
