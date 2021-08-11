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
        guard let firstMonth = calculator?.arbPlayground?.months.first,
              let selectedMonth = calculator?.arbPlaygroundMonth else { return false }

        return firstMonth != selectedMonth
    }

    var ableToSwitchNextMonth: Bool {
        guard let firstMonth = calculator?.arbPlayground?.months.last,
              let selectedMonth = calculator?.arbPlaygroundMonth else { return false }

        return firstMonth != selectedMonth
    }

    var formattedMonthTitle: String {
        calculator?.arbPlaygroundMonth?.monthName ?? ""
    }

    var arb: Arb? {
        calculator?.arb
    }

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    // MARK: - Private properties

    private let arbsManager = ArbsNetworkManager()
    private var arbs: [Arb] = []
    private var calculator: ArbsPlaygroundCalculator?

    // MARK: - Public methods

    func loadData() {
        isLoading = true

        arbsManager.fetchArbsTable { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false

            if case let .success(responseModel) = result,
               let arbs = responseModel.model?.list {

                strongSelf.arbs = arbs
                strongSelf.calculator = .init(arbs: arbs)
                strongSelf.calculator?.delegate = self
                strongSelf.calculator?.chooseNewArb(arbs.first!)

                onMainThread {
                    strongSelf.delegate?.didLoadArbs(strongSelf.arbs)
                    strongSelf.delegate?.didReceiveMonthInfoUpdates()
                }

                strongSelf.calculator?.calculate()
            }
        }
    }

    func showPreviousMonth() {
        calculator?.switchToPrevMonth()
    }

    func showNextMonth() {
        calculator?.switchToNextMonth()
    }

    func changeArb(_ newArb: Arb) {
        calculator?.chooseNewArb(newArb)
    }

    func changeBlendCost(_ newValue: Double) {
        calculator?.changeBlendCost(newValue)
    }

    func changeGasNap(_ newValue: Double) {
        calculator?.changeGasNap(newValue)
    }

    func changeTaArb(_ newValue: Double) {
        calculator?.changeTaArb(newValue)
    }

    func changeEw(_ newValue: Double) {
        calculator?.changeEw(newValue)
    }

    func changeFreight(_ newValue: Int) {
        calculator?.changeFreight(newValue)
    }

    func changeCosts(_ newValue: Double) {
        calculator?.changeCosts(newValue)
    }

    func changeDeliveredPriceSpreadsMonth(_ month: ArbPlaygroundDPS) {
        calculator?.changeDeliveredPriceSpreadsMonth(month)
    }

    func changeUserTgt(_ newValue: Double?) {
        calculator?.changeUserTgt(newValue)
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
                                                         deliveredPriceSpreadsMonth: ArbPlaygroundDPS) {
        delegate?.didReceiveMonthInfoUpdates()

        // blend cost
        let blendCostValue: Double = month.blendCost.value ?? 0.0
        let blendCostRange: ClosedRange<Double> = -5...5

        // gas nap
        let gasNapValue: Double = month.naphtha.value
        let gasNapRange: ClosedRange<Double> = gasNapValue - gasNapValue...abs(gasNapValue + gasNapValue)

        // costs
        let costsValue: Double = month.costs.value ?? 0.0
        let costsRange: ClosedRange<Double> = costsValue - costsValue...abs(costsValue + costsValue)

        let freightUnits = month.freight.units

        var taArbConstructor: ArbPlaygroundPointViewConstructor<Double>?
        var ewConstructor: ArbPlaygroundPointViewConstructor<Double>?
        var freightConstructor: ArbPlaygroundPointViewConstructor<Int>?

        switch freightUnits.lowercased() {
        case "ws":
            if let taArbValue = month.taArb.value {
                let taArbRange: ClosedRange<Double> = taArbValue - taArbValue...abs(taArbValue + taArbValue)
                taArbConstructor = .init(title: "TA Arb", units: month.taArb.units, range: taArbRange, step: 0.25, startValue: taArbValue)
            }

        case "ls":
            if let ewValue = month.ew.value {
                let ewRange: ClosedRange<Double> = ewValue - ewValue...abs(ewValue + ewValue)
                ewConstructor = .init(title: "EW", units: month.taArb.units, range: ewRange, step: 0.1, startValue: ewValue)
            }

        default:
            ewConstructor = nil
            taArbConstructor = nil
            freightConstructor = nil
        }

        if let freightValue = month.freight.value, month.freight.units.lowercased() != "none" {
            let freightValueInt = Int(freightValue)
            let freightRange: ClosedRange<Int> = freightValueInt - freightValueInt...abs(freightValueInt + freightValueInt)
            freightConstructor = .init(title: "Freight", units: month.freight.units, range: freightRange, step: 25_000, startValue: freightValueInt)
        }

        let constructor = ArbPlaygroundInputDataView.Constructor(
            blendCostConstructor: .init(title: "Blend Cost", units: "$/mt", range: blendCostRange, step: 0.25, startValue: blendCostValue),
            gasNapConstructor: .init(title: "Gas-Nap", units: "$/mt", range: gasNapRange, step: 2.5, startValue: gasNapValue),
            freightConstructor: freightConstructor,
            taArbConstructor: taArbConstructor,
            ewConstructor: ewConstructor,
            costsConstructor: .init(title: "Costs", units: "$/mt", range: costsRange, step: 0.25, startValue: costsValue),
            spreadMonthsConstructor: .init(gradeCode: "RBOB", dps: playground.deliveredPriceSpreads, selectedDPS: deliveredPriceSpreadsMonth)
        )

        delegate?.didReceiveInputDataConstructor(constructor)
    }

    func arbsPlaygroundCalculatordDidFinishCalculations(_ results: [ArbsPlaygroundCalculator.Result]) {

        func getColor(for value: Double?) -> UIColor {
            guard let value = value else { return .numberGray }

            if value.isZero {
                return .numberGray
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
                                                                                         value: value.toString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))

            case .deliveredPrice(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "Delivered Price",
                                                                                         value: value.toString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))

            case .cifRefyMargin(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "CIF Refy Mrg",
                                                                                         value: value.toString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))

            case .fobRefyMargin(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "FOB Refy Mrg",
                                                                                         value: value.toString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))

            case .myTgt(let value, let units):
                generatedConstructors.append(ArbPlaygroundResultInputPointViewConstructor(title: "My TGT",
                                                                                          initialInputText: value?.toString,
                                                                                          units: units))

            case .myMargin(let value, let units):

                generatedConstructors.append(ArbPlaygroundResultMainPointViewConstructor(title: "My TGT Margin",
                                                                                         value: value == nil ? "-" : value!.toString,
                                                                                         valueColor: getColor(for: value),
                                                                                         units: units))
            }
        }

        delegate?.didReceiveResultDataConstructors(generatedConstructors)
    }
}
