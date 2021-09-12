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
                                                         deliveredPriceSpreadsMonth: ArbPlaygroundDPS,
                                                         visibleDeliveredPriceSpreadsMonths: [ArbPlaygroundDPS])
    func arbsPlaygroundCalculatordDidFinishCalculations(_ results: [ArbsPlaygroundCalculator.Result])
}

class ArbsPlaygroundCalculator {

    // MARK: - Public properties

    weak var delegate: ArbsPlaygroundCalculatorDelegate?

    let arbs: [Arb]

    var arbMonthPosition: ArbMonth.Position? {
        guard let selectedArbMonthIndex = selectedArbMonthIndex else { return nil }

        return arb.months[selectedArbMonthIndex].position
    }

    private(set) var settings: Settings
    //    private(set) var arbPlayground: ArbPlayground? {
    //        didSet { applyDefaultArbPlaygroundSettings() }
    //    }
    //    private(set) var arbPlaygroundMonth: ArbPlaygroundMonth?
    //    private(set) var deliveredPriceSpreadsMonth: ArbPlaygroundDPS?

    // MARK: - Private properties

    private let arbsManager = ArbsNetworkManager()
    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private(set) var arb: Arb

    private var selectedArbMonthIndex: Int? {
        arb.months
            .firstIndex(where: { $0.name.lowercased() == settings.arbPlaygroundMonth?.monthName.lowercased() })
    }

    // MARK: - Initializers

    init(arbs: [Arb], selectedArb: Arb) {
        self.arbs = arbs
        self.arb = selectedArb
        self.settings = Settings()
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

                strongSelf.settings.applyArbPlayground(arbPlayground)

                onMainThread {
                    strongSelf.delegate?.arbsPlaygroundCalculatorDidChangePlaygroundInfo(strongSelf,
                                                                                         playground: strongSelf.settings.arbPlayground!,
                                                                                         month: strongSelf.settings.arbPlaygroundMonth!,
                                                                                         deliveredPriceSpreadsMonth: strongSelf.settings.deliveredPriceSpreadsMonth!,
                                                                                         visibleDeliveredPriceSpreadsMonths: strongSelf.settings.visibleDeliveredPriceSpreadsMonth)
                }

                strongSelf.calculate()
            } else {
                onMainThread {
                    strongSelf.delegate?.didCatchAnError("Can't fetch arb's playgound")
                }
            }
        }
    }

    func changeDeliveredPriceSpreadsMonth(_ month: ArbPlaygroundDPS) {
        //        deliveredPriceSpreadsMonth = month
        settings.applyArbDeliveredPriceSpreadsMonth(month)
        calculate()
    }

    func changeBlendCost(_ newValue: Double) {
        settings.arbPlaygroundMonth?.blendCost.value = newValue

        if let arbPlaygroundMonth = settings.arbPlaygroundMonth,
           let index = settings.arbPlayground?.months.firstIndex(of: arbPlaygroundMonth),
           let naphthaValue = settings.arbPlayground?.months[index].naphtha.value {

            settings.arbPlaygroundMonth?.naphtha.value = naphthaValue
        }

        calculate()
    }

    func changeGasNap(_ newValue: Double, sign: FloatingPointSign) {
        if let selectedMonth = settings.arbPlayground?.months.first(where: { $0 == settings.arbPlaygroundMonth }),
           let blendCostValue = selectedMonth.blendCost.value {

            let naphtha = selectedMonth.naphtha
            let difference = naphtha.value - newValue
            let result = difference * (naphtha.pricingComponentsVolume / 100)

            settings.arbPlaygroundMonth?.blendCost.value = (blendCostValue + result).round(nearest: 0.25, rule: .up)
            settings.arbPlaygroundMonth?.naphtha.value = newValue
            calculate()
        }
    }

    func changeTaArb(_ newValue: Double) {
        settings.arbPlaygroundMonth?.taArb.value = newValue
        calculate()
    }

    func changeEw(_ newValue: Double) {
        settings.arbPlaygroundMonth?.ew.value = newValue
        calculate()
    }

    func changeFreight(_ newValue: Double) {
        settings.arbPlaygroundMonth?.freight.value = newValue
        calculate()
    }

    func changeCosts(_ newValue: Double) {
        settings.arbPlaygroundMonth?.costs.value = newValue
        calculate()
    }

    func changeUserTgt(_ newValue: Double?) {
        if let selectedArbMonthIndex = selectedArbMonthIndex {
            if let newValue = newValue, !newValue.isZero {
                arb.months[selectedArbMonthIndex].userTarget = newValue
                arb.months[selectedArbMonthIndex].dbProperties.saveUserTarget(value: newValue)
            } else {
                arb.months[selectedArbMonthIndex].userTarget = nil
                arb.months[selectedArbMonthIndex].dbProperties.deleteUserTarget()
            }
        }

        settings.arbPlaygroundMonth?.userTarget.value = newValue
        calculate()
    }

    func switchToMonth(at index: Int) {
        let monthsCount = arb.months.count

        guard index >= 0 && index < monthsCount,
              let currentIndex = selectedArbMonthIndex else { return }

        if currentIndex < index {
            switchToNextMonth()
        } else {
            switchToPrevMonth()
        }
    }

    func switchToPrevMonth() {
        guard let arbPlayground = settings.arbPlayground,
              let arbPlaygroundMonth = settings.arbPlaygroundMonth else { return }

        guard arbPlayground.months.first != arbPlaygroundMonth,
              let currentMonthIndex = arbPlayground.months.firstIndex(of: arbPlaygroundMonth) else { return }

        let prevMonthIndex = arb.months.index(before: currentMonthIndex)

        let newArbMonth = arbPlayground.months[prevMonthIndex]
        settings.applyArbPlaygroundMonth(newArbMonth)

        delegate?.arbsPlaygroundCalculatorDidChangePlaygroundInfo(self,
                                                                  playground: arbPlayground,
                                                                  month: newArbMonth,
                                                                  deliveredPriceSpreadsMonth: settings.deliveredPriceSpreadsMonth!,
                                                                  visibleDeliveredPriceSpreadsMonths: settings.visibleDeliveredPriceSpreadsMonth)
        calculate()
    }

    func switchToNextMonth() {
        guard let arbPlayground = settings.arbPlayground,
              let arbPlaygroundMonth = settings.arbPlaygroundMonth else { return }

        guard arbPlayground.months.last != arbPlaygroundMonth,
              let currentMonthIndex = arbPlayground.months.firstIndex(of: arbPlaygroundMonth) else { return }

        let nextMonthIndex = arbPlayground.months.index(after: currentMonthIndex)

        let newArbMonth = arbPlayground.months[nextMonthIndex]
        settings.applyArbPlaygroundMonth(newArbMonth)

        delegate?.arbsPlaygroundCalculatorDidChangePlaygroundInfo(self,
                                                                  playground: arbPlayground,
                                                                  month: newArbMonth,
                                                                  deliveredPriceSpreadsMonth: settings.deliveredPriceSpreadsMonth!,
                                                                  visibleDeliveredPriceSpreadsMonths: settings.visibleDeliveredPriceSpreadsMonth)
        calculate()
    }

    func calculate() {
        guard let arbPlayground = settings.arbPlayground else {
            onMainThread {
                self.delegate?.didCatchAnError("Didn't choosed arbPlayground")
            }

            return
        }

        calculate(for: arbPlayground)
    }

    // MARK: - Private methods

    private func calculate(for arbPlayground: ArbPlayground) {
        print("DEBUG ***: Result of calculations")

        guard let month = settings.arbPlaygroundMonth,
              let deliveredPriceSpreadsMonth = settings.deliveredPriceSpreadsMonth,
              let selectedArbMonthIndex = selectedArbMonthIndex else { return }

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
        let userTarget = arb.months[selectedArbMonthIndex].userTarget
        let userTargetMargin: Double? = userTarget == nil ? nil : userTarget! - deliveredPriceDefault

        print("Results -------:")

        let gradeCode = arb.gradeCode.lowercased()
        var results: [Result] = []

        results.append(.deliveredPrice(value: deliveredPrice.round(nearest: 0.05, rule: .up), units: units))

        if gradeCode == "e5eurobob" {
            results.append(.blenderMargin(value: blenderMargin.round(nearest: 0.05, rule: .up), units: units))
            results.append(.fobRefyMargin(value: fobRefyMargin.round(nearest: 0.05, rule: .up), units: units))
        } else if gradeCode == "rbob"
                    || gradeCode == "sing92ron" {

            results.append(.blenderMargin(value: blenderMargin.round(nearest: 0.05, rule: .up), units: units))
            results.append(.fobRefyMargin(value: fobRefyMargin.round(nearest: 0.05, rule: .up), units: units))
            results.append(.cifRefyMargin(value: cifRefyMargin.round(nearest: 0.05, rule: .up), units: units))
        }

        if let blenderMarginChangeOnDay = arb.months[selectedArbMonthIndex].genericBlenderMarginChangeOnDay?.value.toDouble {
            results.append(.codBlenderMargin(value: blenderMarginChangeOnDay.round(nearest: 0.05, rule: .up),
                                             units: units))
        }

        results.append(.myTgt(value: month.userTarget.value, units: units))
        results.append(.myMargin(value: userTargetMargin?.round(nearest: 0.05, rule: .up), units: units))

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
        case codBlenderMargin(value: Double, units: String)
        case myTgt(value: Double?, units: String)
        case myMargin(value: Double?, units: String)
    }
}
