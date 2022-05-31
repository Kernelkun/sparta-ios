//
//  ACDeliveryDateInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.04.2022.
//

import Foundation
import NetworkingModels

protocol ACDeliveryDateViewModelDelegate: AnyObject {
    func acDeliveryDateViewModelDidChangeLoadingState(_ isLoading: Bool)
    func acDeliveryDateViewModelDidCatchAnError(_ error: String)
    func acDeliveryDateViewModelDidFetchMonthsSelector(_ selector: MonthsSelector)
    func acDeliveryDateViewModelDidFetchPortfolios(_ portfolios: [Arb.Portfolio])
    func acDeliveryDateViewModelDidFetchArbsVModel(_ model: ACDeliveryDateUIModel)
}

protocol ACDeliveryDateViewModelInterface {
    var monthsSelector: MonthsSelector? { get }
    var delegate: ACDeliveryDateViewModelDelegate? { get set }

    func loadData()
    func switchToPrevMonth()
    func switchToNextMonth()
    func makeActivePortfolio(_ portfolio: Arb.Portfolio)
}
