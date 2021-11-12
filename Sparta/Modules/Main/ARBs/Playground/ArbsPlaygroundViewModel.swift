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
    func didLoadArbs(_ arbs: [Arb])
    func didReceiveMonthInfoUpdates()
    func didReceiveInputDataConstructor(_ constructor: ArbPlaygroundInputDataView.Constructor)
    func didReceiveResultDataConstructors(_ constructors: [ArbPlaygroundResultViewConstructor])
}

class ArbsPlaygroundViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbsPlaygroundViewModelDelegate?

    var ableToSwitchPrevMonth: Bool {
        guard let firstMonth = calculator.settings.arbPlayground?.months.first,
              let selectedMonth = calculator.settings.arbPlaygroundMonth else { return false }

        return firstMonth != selectedMonth
    }

    var ableToSwitchNextMonth: Bool {
        guard let firstMonth = calculator.settings.arbPlayground?.months.last,
              let selectedMonth = calculator.settings.arbPlaygroundMonth else { return false }

        return firstMonth != selectedMonth
    }

    var formattedMonthTitle: String {
        calculator.settings.arbPlaygroundMonth?.monthName ?? ""
    }

    var arb: Arb { calculator.arb }

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    // MARK: - Private properties

    private let calculator: ArbsPlaygroundCalculator

    // MARK: - Initializers

    init(selectedArb: Arb) {
        let arbs = App.instance.arbsSyncManager.portfolios.first(where: { $0.portfolio.isAra })?.arbs ?? []
        calculator = .init(arbs: arbs, selectedArb: selectedArb)
        super.init()

        calculator.delegate = self
    }

    // MARK: - Public methods

    func loadData() {
        calculator.chooseNewArb(calculator.arb)

        onMainThread {
            self.delegate?.didLoadArbs(self.calculator.arbs)
            self.delegate?.didReceiveMonthInfoUpdates()
        }
    }

    func switchToMonth(at index: Int) {
        calculator.switchToMonth(at: index)
    }

    func showPreviousMonth() {
        calculator.switchToPrevMonth()
    }

    func showNextMonth() {
        calculator.switchToNextMonth()
    }

    func changeArb(_ newArb: Arb) {
        calculator.chooseNewArb(newArb)
    }

    func changeBlendCost(_ newValue: Double) {
        calculator.changeBlendCost(newValue)
    }

    func changeGasNap(_ newValue: Double, sign: FloatingPointSign) {
        calculator.changeGasNap(newValue, sign: sign)
    }

    func changeTaArb(_ newValue: Double) {
        calculator.changeTaArb(newValue)
    }

    func changeEw(_ newValue: Double) {
        calculator.changeEw(newValue)
    }

    func changeFreight(_ newValue: Double) {
        calculator.changeFreight(newValue)
    }

    func changeCosts(_ newValue: Double) {
        calculator.changeCosts(newValue)
    }

    func changeDeliveredPriceSpreadsMonth(_ month: ArbPlaygroundDPS) {
        calculator.changeDeliveredPriceSpreadsMonth(month)
    }

    func changeUserTgt(_ newValue: Double?) {
        calculator.changeUserTgt(newValue)
    }
}

extension ArbsPlaygroundViewModel: ArbsPlaygroundCalculatorDelegate {
    func didChangeLoadingState(_ isLoading: Bool) {
        self.isLoading = isLoading
    }

    func didCatchAnError(_ error: String) {
    }

    func arbsPlaygroundCalculatorDidChangeMonth(_ calculator: ArbsPlaygroundCalculator, month: ArbPlaygroundMonth) {
        delegate?.didReceiveMonthInfoUpdates()
    }

    func arbsPlaygroundCalculatorDidChangePlaygroundInfo(_ calculator: ArbsPlaygroundCalculator,
                                                         playground: ArbPlayground,
                                                         month: ArbPlaygroundMonth,
                                                         deliveredPriceSpreadsMonth: ArbPlaygroundDPS,
                                                         visibleDeliveredPriceSpreadsMonths: [ArbPlaygroundDPS]) {
        delegate?.didReceiveMonthInfoUpdates()

        func generateRange<V: Numeric>(with step: V, initialValue: V) -> ClosedRange<V> {
            initialValue - step...initialValue + step
        }

        // blend cost
        let blendCostValue: Double = month.blendCost.value ?? 0.0
        let blendCostRange: ClosedRange<Double> = generateRange(with: 2.5, initialValue: blendCostValue)

        // gas nap
        let gasNapTitle = "Gas-Nap"
        let gasNapSubTitle = "(Nap in Bld = \(month.naphtha.pricingComponentsVolume.round(nearest: 1))%)"
        let gasNapValue: Double = month.naphtha.value
        let gasNapRange: ClosedRange<Double> = generateRange(with: 25, initialValue: gasNapValue)

        // costs
        let costsValue: Double = month.costs.value ?? 0.0
        let costsRange: ClosedRange<Double> = generateRange(with: 2.5, initialValue: costsValue)

        let freightUnits = month.freight.units

        var taArbConstructor: ArbPlaygroundPointViewConstructor<Double>?
        var ewConstructor: ArbPlaygroundPointViewConstructor<Double>?
        var freightDConstructor: ArbPlaygroundPointViewConstructor<Double>?
        var freightIConstructor: ArbPlaygroundPointViewConstructor<Int>?

        switch freightUnits.lowercased() {
        case "ws":
            if let taArbValue = month.taArb.value {
                let taArbRange: ClosedRange<Double> = generateRange(with: 2.5, initialValue: taArbValue)
                taArbConstructor = .init(title: "TA Arb", subTitle: nil, units: month.taArb.units, range: taArbRange, step: 0.25, startValue: taArbValue)
            }

        case "ls":
            if let ewValue = month.ew.value {
                let ewRange: ClosedRange<Double> = generateRange(with: 2.5, initialValue: ewValue)
                ewConstructor = .init(title: "EW", subTitle: nil, units: month.ew.units, range: ewRange, step: 0.25, startValue: ewValue)
            }

        default:
            ewConstructor = nil
            taArbConstructor = nil
            freightDConstructor = nil
            freightIConstructor = nil
        }

        if let freightValue = month.freight.value, month.freight.units.lowercased() != "none" {
            let units: String

            if month.freight.units.lowercased() == "ls" {
                units = "$"
                let step: Int = 25_000
                let freightRange: ClosedRange<Int> = generateRange(with: 250_000, initialValue: Int(freightValue))
                freightIConstructor = .init(title: "Freight", subTitle: nil, units: units, range: freightRange, step: step, startValue: Int(freightValue))
                freightDConstructor = nil
            } else {
                units = "WS"
                let step: Double = 2.5
                let freightRange: ClosedRange<Double> = generateRange(with: 25, initialValue: freightValue)
                freightDConstructor = .init(title: "Freight", subTitle: nil, units: units, range: freightRange, step: step, startValue: freightValue)
                freightIConstructor = nil
            }
        }

        let constructor = ArbPlaygroundInputDataView.Constructor(
            statusPosition: calculator.arbMonthPosition,
            blendCostConstructor: .init(title: "Blend Cost", subTitle: nil, units: "$/mt", range: blendCostRange, step: 0.25, startValue: blendCostValue),
            gasNapConstructor: .init(title: gasNapTitle, subTitle: gasNapSubTitle, units: "$/mt", range: gasNapRange, step: 2.5, startValue: gasNapValue),
            freightDConstructor: freightDConstructor,
            freightIConstructor: freightIConstructor,
            taArbConstructor: taArbConstructor,
            ewConstructor: ewConstructor,
            costsConstructor: .init(title: "Costs", subTitle: nil, units: "$/mt", range: costsRange, step: 0.25, startValue: costsValue),
            spreadMonthsConstructor: .init(gradeCode: deliveredPriceSpreadsMonth.name, dps: visibleDeliveredPriceSpreadsMonths, selectedDPS: deliveredPriceSpreadsMonth)
        )

        delegate?.didReceiveInputDataConstructor(constructor)
    }

    func arbsPlaygroundCalculatordDidFinishCalculations(_ results: [ArbsPlaygroundCalculator.Result]) {

        func getColor(for value: Double?) -> UIColor {
            guard let value = value else { return .numberGray }

            if value.isZero {
                return .plMainText
            } else if value.sign == .minus {
                return .numberRed
            } else {
                return .numberGreen
            }
        }

        var generatedConstructors: [ArbPlaygroundResultViewConstructor] = []
        results.forEach { result in
            switch result {
            case .blenderMargin(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "Blender Margin",
                                                                                         value: value.toFormattedString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))

            case .deliveredPrice(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "Delivered Price",
                                                                                         value: value.toFormattedString,
                                                                                         valueColor: .plMainText,
                                                                                         units: units))

            case .cifRefyMargin(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "CIF Refy Mrg",
                                                                                         value: value.toFormattedString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))

            case .fobRefyMargin(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "FOB Refy Mrg",
                                                                                         value: value.toFormattedString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))

            case .codBlenderMargin(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "CoD Blender Margin",
                                                                                         value: value.toFormattedString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))

            case .myTgt(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultInputPointViewConstructor(title: "My TGT",
                                                                                          initialInputText: value?.toFormattedString,
                                                                                          units: units))

            case .myMargin(let value, let units):

                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "My TGT Margin",
                                                                                         value: value == nil ? "-" : value!.toFormattedString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))
            }
        }

        delegate?.didReceiveResultDataConstructors(generatedConstructors)

        arbsPlaygroundCalculatorDidChangePlaygroundInfo(calculator,
                                                        playground: calculator.settings.arbPlayground!,
                                                        month: calculator.settings.arbPlaygroundMonth!,
                                                        deliveredPriceSpreadsMonth: calculator.settings.deliveredPriceSpreadsMonth!,
                                                        visibleDeliveredPriceSpreadsMonths: calculator.settings.visibleDeliveredPriceSpreadsMonth
                                                        )
    }
}
