//
//  FreightCalculator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.01.2021.
//

import Foundation
import SpartaHelpers
import NetworkingModels

protocol FreightCalculatorDelegate: class {
    func didChangeLoadingState(_ isLoading: Bool)
    func didCatchAnError(_ error: String)
    func didFinishCalculations(_ calculatedTypes: [FreightCalculator.CalculatedType])
}

class FreightCalculator {

    // MARK: - Public properties

    weak var delegate: FreightCalculatorDelegate?

    private(set) var inputData: InputData

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private var availableMonths: [Date] {
        Date.fetchNextMonths(count: 14)
    }

    private let analyticsNetworkManager = AnalyticsNetworkManager()

    // MARK: - Initializers

    init(inputData: InputData) {
        self.inputData = inputData
    }

    // MARK: - Public variables

    var ableToCalculatePrevMonth: Bool {
        availableMonths.first != inputData.month
    }

    var ableToCalculateNextMonth: Bool {
        availableMonths.last != inputData.month
    }

    // MARK: - Public methods

    func switchToPrevMonth() {
        guard availableMonths.first != inputData.month,
              let currentMonthIndex = availableMonths.firstIndex(of: inputData.month) else { return }

        let prevMonthIndex = availableMonths.index(before: currentMonthIndex)

        inputData.month = availableMonths[prevMonthIndex]
    }

    func switchToNextMonth() {
        guard availableMonths.last != inputData.month,
              let currentMonthIndex = availableMonths.firstIndex(of: inputData.month) else { return }

        let nextMonthIndex = availableMonths.index(after: currentMonthIndex)

        inputData.month = availableMonths[nextMonthIndex]
    }

    func calculate() {

        isLoading = true

        let formattedMonth = inputData.month.formattedString(AppFormatter.serverShortDate)
        analyticsNetworkManager.fetchFreightRoute(loadPortId: inputData.portId,
                                                  dischargePortId: inputData.dischargePortId,
                                                  selectedDate: formattedMonth) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let responseModel) where responseModel.model != nil:

                if let newVessel = responseModel.model?.vessels.first(where: { $0.type == strongSelf.inputData.vessel.type }) {
                    strongSelf.inputData.vessel = newVessel

                    onMainThread {
                        strongSelf.delegate?.didFinishCalculations(strongSelf.calculateTypes())
                    }
                } else {
                    onMainThread {
                        strongSelf.delegate?.didCatchAnError("Can't fetch data from server")
                    }
                }

            case .success, .failure:
                onMainThread {
                    strongSelf.delegate?.didCatchAnError("Can't fetch data from server")
                }
            }

            strongSelf.isLoading = false
        }
    }

    // MARK: - Private methods

    private func formattedJourneyTime() -> String {

        let journeyDistance = inputData.vessel.distance
        let vesselSpeed = inputData.vesselSpeed

        let totalJourneyHours = Int(journeyDistance / vesselSpeed)
        let days = Int(totalJourneyHours / 24)
        let hours = totalJourneyHours % 24

        return "\(days) days \(hours) hours"
    }

    private func calculatedRate() -> Double {

        let vessel = inputData.vessel
        let lumpsum: Double

        if vessel.routeType.lowercased() == "LS".lowercased() {
            lumpsum = vessel.routeTypeValue
        } else {
            let wsInPercentage = vessel.routeTypeValue / 100

            if inputData.loadedQuantity <= vessel.cpBasis {
                lumpsum = vessel.cpBasis * vessel.flatRate * wsInPercentage
            } else {
                let firstCondition = inputData.loadedQuantity - vessel.cpBasis
                lumpsum = vessel.cpBasis * vessel.flatRate * wsInPercentage + firstCondition * vessel.flatRate * wsInPercentage * vessel.overage
            }
        }

        return lumpsum / inputData.loadedQuantity
    }

    private func calculateTypes() -> [CalculatedType] {
        var types: [CalculatedType] = []

        var routeValue: String = ""

        if inputData.vessel.routeType.lowercased() == "ws".lowercased() {
            routeValue = round(inputData.vessel.routeTypeValue).toFormattedString
        } else {
            routeValue = round(inputData.vessel.routeTypeValue, toNearest: 5000).toFormattedString
            routeValue.insert("$", at: routeValue.startIndex)
        }

        types.append(.route(title: inputData.vessel.routeType, value: routeValue))
        types.append(.rate(value: "\(calculatedRate().round(to: 2).toFormattedString) $/mt"))
        types.append(.cpBasis(value: "\(inputData.vessel.cpBasis.toFormattedString) mt"))

        if !inputData.vessel.overage.isZero {
            types.append(.overage(value: inputData.vessel.overage.toFormattedPercentageString))
        }

        if !inputData.vessel.marketCondition.isEmpty {
            types.append(.marketCondition(value: inputData.vessel.marketCondition))
        }

        types.append(.journeyTime(value: formattedJourneyTime()))
        types.append(.journeyDistance(value: "\(inputData.vessel.distance.toFormattedString) nm"))

        return types
    }
}

extension FreightCalculator {

    struct InputData {

        // MARK: - Public variables

        var month: Date
        let portId: Int
        let dischargePortId: Int
        var vessel: Vessel
        let vesselSpeed: Double
        let loadedQuantity: Double
    }

    enum CalculatedType {
        case route(title: String, value: String)
        case rate(value: String)
        case cpBasis(value: String)
        case overage(value: String)
        case marketCondition(value: String)
        case journeyTime(value: String)
        case journeyDistance(value: String)
    }
}
