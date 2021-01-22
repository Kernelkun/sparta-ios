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
    func didUpdateMonthsInformation()
    func didFinishCalculations(_ calculatedTypes: [FreightCalculator.CalculatedType])
}

class ArbDetailViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbDetailViewModelDelegate?

    var ableToCalculatePrevMonth: Bool {
        calculator.ableToCalculatePrevMonth
    }

    var ableToCalculateNextMonth: Bool {
        calculator.ableToCalculateNextMonth
    }

    var formattedMonthTitle: String {
        calculator.inputData.month.formattedString(AppFormatter.fullMonthAndYear)
    }

    // MARK: - Private properties

    private let calculator: FreightCalculator

    // MARK: - Initializers

    init(inputData: FreightCalculator.InputData) {
        calculator = FreightCalculator(inputData: inputData)

        super.init()

        calculator.delegate = self
    }

    // MARK: - Public methods

    func switchToPrevMonth() {
        calculator.switchToPrevMonth()
        delegate?.didUpdateMonthsInformation()
        calculator.calculate()
    }

    func switchToNextMonth() {
        calculator.switchToNextMonth()
        delegate?.didUpdateMonthsInformation()
        calculator.calculate()
    }

    func loadData() {
        delegate?.didUpdateMonthsInformation()
        calculator.calculate()
    }
}

extension ArbDetailViewModel: FreightCalculatorDelegate {

    func didChangeLoadingState(_ isLoading: Bool) {
        onMainThread {
            self.delegate?.didChangeLoadingState(isLoading)
        }
    }

    func didCatchAnError(_ error: String) {
        onMainThread {
            self.delegate?.didCatchAnError(error)
        }
    }

    func didFinishCalculations(_ calculatedTypes: [FreightCalculator.CalculatedType]) {
        onMainThread {
            self.delegate?.didFinishCalculations(calculatedTypes)
        }
    }
}
