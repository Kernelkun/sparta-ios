//
//  ArbsPlaygroundCalculator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.08.2021.
//

import Foundation
import NetworkingModels

protocol ArbsPlaygroundCalculatorDelegate: AnyObject {
    func didChangeLoadingState(_ isLoading: Bool)
    func didCatchAnError(_ error: String)
    func arbsPlaygroundCalculatorDidChangePlaygroundInfo(_ calculator: ArbsPlaygroundCalculator,
                                                         playground: ArbPlayground,
                                                         month: ArbPlaygroundMonth,
                                                         deliveredPriceSpreadsMonth: ArbPlaygroundDPS)
    func arbsPlaygroundCalculatordDidFinishCalculations(_ results: [ArbsPlaygroundCalculator.Result])
}

class ArbsPlaygroundCalculator {

    // MARK: - Public properties

    weak var delegate: ArbsPlaygroundCalculatorDelegate?

    let arbs: [Arb]
    private(set) var arbPlayground: ArbPlayground? {
        didSet { applyDefaultArbPlaygroundSettings() }
    }
    private(set) var arbPlaygroundMonth: ArbPlaygroundMonth?
    private(set) var deliveredPriceSpreadsMonth: ArbPlaygroundDPS?

    // MARK: - Private properties

    private let arbsManager = ArbsNetworkManager()
    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private(set) var arb: Arb!

    // MARK: - Initializers

    init(arbs: [Arb]) {
        self.arbs = arbs
    }

    // MARK: - Public methods

    func chooseNewArb(_ arb: Arb) {
        guard let arbIndex = arbs.firstIndex(of: arb) else { return }

        self.arb = arbs[arbIndex]

        isLoading = true

        arbsManager.fetchArbPlayground(for: arb) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false

            if case let .success(responseModel) = result,
               let arbPlayground = responseModel.model {

                strongSelf.arbPlayground = arbPlayground
                strongSelf.calculate()
            } else {
                onMainThread {
                    strongSelf.delegate?.didCatchAnError("Can't fetch arb's playgound")
                }
            }
        }
    }

    func changeDeliveredPriceSpreadsMonth(_ month: ArbPlaygroundDPS) {
        deliveredPriceSpreadsMonth = month
        calculate()
    }

    func changeBlendCost(_ newValue: Double) {
        arbPlaygroundMonth?.blendCost.value = newValue

        if let arbPlaygroundMonth = arbPlaygroundMonth,
           let index = arbPlayground?.months.firstIndex(of: arbPlaygroundMonth),
           let naphthaValue = arbPlayground?.months[index].naphtha.value {

            self.arbPlaygroundMonth?.naphtha.value = naphthaValue
        }

        calculate()
    }

    func changeGasNap(_ newValue: Double, sign: FloatingPointSign) {
        if let naphtha = arbPlaygroundMonth?.naphtha, let oldValue = arbPlaygroundMonth?.blendCost.value {
            let difference = abs(newValue - naphtha.value) * (naphtha.pricingComponentsVolume / 100)

            arbPlaygroundMonth?.blendCost.value = oldValue + Double(sign: sign, exponent: 0, significand: difference)

        }

        arbPlaygroundMonth?.naphtha.value = newValue
        calculate()
    }

    func changeTaArb(_ newValue: Double) {
        arbPlaygroundMonth?.taArb.value = newValue
        calculate()
    }

    func changeEw(_ newValue: Double) {
        arbPlaygroundMonth?.ew.value = newValue
        calculate()
    }

    func changeFreight(_ newValue: Double) {
        arbPlaygroundMonth?.freight.value = newValue
        calculate()
    }

    func changeCosts(_ newValue: Double) {
        arbPlaygroundMonth?.costs.value = newValue
        calculate()
    }

    func changeUserTgt(_ newValue: Double?) {
        arbPlaygroundMonth?.userTarget.value = newValue
        calculate()
    }

    func switchToPrevMonth() {
        guard var arbPlayground = arbPlayground,
              let arbPlaygroundMonth = arbPlaygroundMonth,
              let deliveredPriceSpreadsMonth = deliveredPriceSpreadsMonth else { return }

        guard arbPlayground.months.first != arbPlaygroundMonth,
              let currentMonthIndex = arbPlayground.months.firstIndex(of: arbPlaygroundMonth) else { return }

        let prevMonthIndex = arb.months.index(before: currentMonthIndex)

        let newArbMonth = arbPlayground.months[prevMonthIndex]
        self.arbPlaygroundMonth = newArbMonth

        // months

        if let startIndex = arbPlayground.deliveredPriceSpreads
            .firstIndex(where: { $0.monthName.lowercased() == newArbMonth.monthName.lowercased() }) {

            let finalIndex = startIndex + 4
            if finalIndex < arbPlayground.deliveredPriceSpreads.count {
                arbPlayground.deliveredPriceSpreads = Array(arbPlayground.deliveredPriceSpreads[startIndex...finalIndex])
            } else {
                arbPlayground.deliveredPriceSpreads = Array(arbPlayground.deliveredPriceSpreads[startIndex...])
            }
        }

        if !arbPlayground.deliveredPriceSpreads.contains(deliveredPriceSpreadsMonth),
           let firstMonth = arbPlayground.deliveredPriceSpreads.first {

            self.deliveredPriceSpreadsMonth = firstMonth
        }

        delegate?.arbsPlaygroundCalculatorDidChangePlaygroundInfo(self,
                                                                  playground: arbPlayground,
                                                                  month: newArbMonth,
                                                                  deliveredPriceSpreadsMonth: self.deliveredPriceSpreadsMonth!)
        calculate()
    }

    func switchToNextMonth() {
        guard var arbPlayground = arbPlayground,
              let arbPlaygroundMonth = arbPlaygroundMonth,
              let deliveredPriceSpreadsMonth = deliveredPriceSpreadsMonth else { return }

        guard arbPlayground.months.last != arbPlaygroundMonth,
              let currentMonthIndex = arbPlayground.months.firstIndex(of: arbPlaygroundMonth) else { return }

        let nextMonthIndex = arbPlayground.months.index(after: currentMonthIndex)

        let newArbMonth = arbPlayground.months[nextMonthIndex]
        self.arbPlaygroundMonth = newArbMonth

        // months

        if let startIndex = arbPlayground.deliveredPriceSpreads
            .firstIndex(where: { $0.monthName.lowercased() == newArbMonth.monthName.lowercased() }) {

            let finalIndex = startIndex + 4
            if finalIndex < arbPlayground.deliveredPriceSpreads.count {
                arbPlayground.deliveredPriceSpreads = Array(arbPlayground.deliveredPriceSpreads[startIndex...finalIndex])
            } else {
                arbPlayground.deliveredPriceSpreads = Array(arbPlayground.deliveredPriceSpreads[startIndex...])
            }
        }

        if !arbPlayground.deliveredPriceSpreads.contains(deliveredPriceSpreadsMonth),
           let firstMonth = arbPlayground.deliveredPriceSpreads.first {

            self.deliveredPriceSpreadsMonth = firstMonth
        }

        delegate?.arbsPlaygroundCalculatorDidChangePlaygroundInfo(self,
                                                                  playground: arbPlayground,
                                                                  month: newArbMonth,
                                                                  deliveredPriceSpreadsMonth: self.deliveredPriceSpreadsMonth!)

        calculate()
    }

    func calculate() {
        guard let arbPlayground = arbPlayground else {
            onMainThread {
                self.delegate?.didCatchAnError("Didn't choosed arbPlayground")
            }

            return
        }

        calculate(for: arbPlayground)
    }

    // MARK: - Private methods

    private func applyDefaultArbPlaygroundSettings() {
        guard var arbPlayground = arbPlayground else { return }

        arbPlaygroundMonth = arbPlayground.months.first
        deliveredPriceSpreadsMonth = arbPlayground.deliveredPriceSpreads.first

        // months

        let finalIndex = 4
        if finalIndex < arbPlayground.deliveredPriceSpreads.count {
            arbPlayground.deliveredPriceSpreads = Array(arbPlayground.deliveredPriceSpreads[0...finalIndex])
        } else {
            arbPlayground.deliveredPriceSpreads = Array(arbPlayground.deliveredPriceSpreads[0...])
        }

        guard let arbPlaygroundMonth = arbPlaygroundMonth,
              let deliveredPriceSpreadsMonth = deliveredPriceSpreadsMonth else { return }

        onMainThread {
            self.delegate?.arbsPlaygroundCalculatorDidChangePlaygroundInfo(self,
                                                                           playground: arbPlayground,
                                                                           month: arbPlaygroundMonth,
                                                                           deliveredPriceSpreadsMonth: deliveredPriceSpreadsMonth)
        }
    }

    private func calculate(for arbPlayground: ArbPlayground) {
        print("DEBUG ***: Result of calculations")

        guard let arb = arb,
              let month = arbPlaygroundMonth,
              let deliveredPriceSpreadsMonth = deliveredPriceSpreadsMonth else { return }

        let blendCost = month.blendCost
        let blendCostValue = blendCost.value ?? 0.0//.round(to: 2)
        print("Blend Cost: \(blendCostValue), unit: \(blendCost.units)")

        let gasNaphtha = month.naphtha
        print("Gas Nap: \(gasNaphtha.value), pricingComponentsVolume: \(gasNaphtha.pricingComponentsVolume)")

        let costs = month.costs
        let costsValue = (month.costs.value ?? 0.0)//.round(to: 2)
        print("Costs: \(costsValue), unit: \(costs.units)")

        print("Dlv price basis: \(deliveredPriceSpreadsMonth.name)")

        print("------")

        print("Delivered Price: \(deliveredPriceSpreadsMonth.value)")

        // rate
        let loadedQuantity = month.loadedQuantity.value ?? 0.0
        let freightRate = calculateRate(for: arb, loadedQuantity: loadedQuantity, freightRate: month.freight.value ?? 0.0)

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

        let foundDlvdIndex = arbPlayground.deliveredPriceSpreads.firstIndex(of: deliveredPriceSpreadsMonth)!

        let spreadToSum = getSpreadSumForMonths(month: month,
                                                dlvdPriceBasisMonth: deliveredPriceSpreadsMonth,
                                                spreadMonths: arbPlayground.deliveredPriceSpreads)

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
            deliveredPrice = priceBeforeTAEW / 8.33 - ew + defaultCalculationSum
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
        let userTargetMargin: Double? = month.userTarget.value == nil ? nil : month.userTarget.value! - deliveredPriceDefault

        print("Results -------:")

        let gradeCode = arb.gradeCode.lowercased()
        var results: [Result] = []

        results.append(.deliveredPrice(value: deliveredPrice.round(to: 2), units: units))

        if gradeCode == "e5eurobob" {
            results.append(.blenderMargin(value: blenderMargin.round(to: 2), units: units))
            results.append(.fobRefyMargin(value: fobRefyMargin.round(to: 2), units: units))
        } else if gradeCode == "rbob"
                    || gradeCode == "sing92ron" {

            results.append(.blenderMargin(value: blenderMargin.round(to: 2), units: units))
            results.append(.fobRefyMargin(value: fobRefyMargin.round(to: 2), units: units))
            results.append(.cifRefyMargin(value: cifRefyMargin.round(to: 2), units: units))
        }

        results.append(.myTgt(value: month.userTarget.value, units: units))
        results.append(.myMargin(value: userTargetMargin?.round(to: 2), units: units))

        onMainThread {
            self.delegate?.arbsPlaygroundCalculatordDidFinishCalculations(results)
        }
    }

    private func calculateRate(for arb: Arb, loadedQuantity: Double, freightRate: Double) -> Double {
        let vessel = arb.freight.vessel
        let lumpsum: Double

        if vessel.routeType.lowercased() == "LS".lowercased() {
            lumpsum = freightRate //vessel.routeTypeValue
        } else {
            let wsInPercentage = /*vessel.routeTypeValue*/ freightRate / 100

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

            return spreadMonths[monthIndex..<defaultSpreadMonthIndex].compactMap { $0.value }.reduce(0, +)
        } else {
            return 0
        }
    }

    private func getSpreadSumForMonths(month: ArbPlaygroundMonth, dlvdPriceBasisMonth: ArbPlaygroundDPS, spreadMonths: [ArbPlaygroundDPS]) -> Double {
        guard dlvdPriceBasisMonth.monthName != month.defaultSpreadMonthName else {
            return 0
        }

        guard let defaultDlvdPriceMonthIndex = spreadMonths.firstIndex(where: { $0.monthName == month.defaultSpreadMonthName }),
              let selectedDlvdPriceMonthIndex = spreadMonths.firstIndex(where: { $0.monthName == dlvdPriceBasisMonth.monthName })
        else {
            return 0
        }

        if selectedDlvdPriceMonthIndex < defaultDlvdPriceMonthIndex {
            return spreadMonths[selectedDlvdPriceMonthIndex].value * -1
        }

        return spreadMonths[defaultDlvdPriceMonthIndex..<selectedDlvdPriceMonthIndex].reduce(0, { result, month in
            result + month.value
        })
    }
}

extension ArbsPlaygroundCalculator {

    enum Result {
        case deliveredPrice(value: Double, units: String)
        case blenderMargin(value: Double, units: String)
        case fobRefyMargin(value: Double, units: String)
        case cifRefyMargin(value: Double, units: String)
        case myTgt(value: Double?, units: String)
        case myMargin(value: Double?, units: String)
    }
}
