//
//  ACDeliveryDateViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.04.2022.
//

import Foundation
import NetworkingModels

/// Instruction how to fetch this table
///
/// 1. Need to fetch portfolios list
/// 2. Then fetch table with specific

class ACDeliveryDateViewModel: ACDeliveryDateViewModelInterface {

    // MARK: - Public properties

    var monthsSelector: MonthsSelector?
    weak var delegate: ACDeliveryDateViewModelDelegate?

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.acDeliveryDateViewModelDidChangeLoadingState(self.isLoading)
            }
        }
    }

    private let arbsNetworkManager = ArbsNetworkManager()

    // MARK: - Public methods

    func loadData() {
        isLoading = true

        let request = GetArbsPortfoliosRequest(type: .comparisonByMonth)
        arbsNetworkManager.fetchArbsPortfolios(request: request) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false

            if case let .success(responseModel) = result,
               let portfolios = responseModel.model?.list {

                if let firstPortfolio = portfolios.first {
                    strongSelf.makeActivePortfolio(firstPortfolio)
                }

                onMainThread {
                    strongSelf.delegate?.acDeliveryDateViewModelDidFetchPortfolios(portfolios)
                }
            }
        }
    }

    func makeActivePortfolio(_ portfolio: Arb.Portfolio) {
        isLoading = true

        let request: ArbVTableRequest = .init(
            arbIds: nil,
            portfolioId: portfolio.id,
            dateRange: .month
        )

        arbsNetworkManager.fetchVTableArbsInfo(request: request) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false

            if case let .success(responseModel) = result,
                let list = responseModel.model?.list {

                let groupedByLoadRegion = Dictionary(grouping: list, by: { $0.loadRegion })

                let rows: [ACDeliveryDateUIModel.Row] = groupedByLoadRegion.compactMap { value -> ACDeliveryDateUIModel.Row in
                    let title = value.key
                    let groups = Dictionary(
                        grouping: value.value,
                        by: { $0.grade }
                    ).compactMap { value -> ACDeliveryDateUIModel.ArbVGroup in
                        ACDeliveryDateUIModel.ArbVGroup(grade: value.key, arbsV: value.value)
                    }

                    return .init(title: title, groups: groups)
                }

                let headers = rows.first?.groups.compactMap { group -> ACDeliveryDateUIModel.Header? in
                    guard let arbV = group.arbsV.first else { return nil }

                    return ACDeliveryDateUIModel.Header(title: arbV.grade, units: arbV.units)
                } ?? []

                var activeModel: ACDeliveryDateUIModel.Active!

                if let arbV = rows.first?.groups.first?.arbsV.first, let value = arbV.values.first {
                    activeModel = ACDeliveryDateUIModel.Active(arbV: arbV, arbVValue: value)
                }

                let uiModel = ACDeliveryDateUIModel(headers: headers, rows: rows, active: activeModel)

                /// MONTHS

                var finalMonths: [String] = []
                list.forEach { $0.values.forEach { finalMonths.append($0.deliveryMonth)  } }

                let months = Array(Set(finalMonths)).sorted(by: { dateString1, dateString2 in
                    guard let date1 = DateFormatter.mmmYY.date(from: dateString1),
                          let date2 = DateFormatter.mmmYY.date(from: dateString2) else { return false }
                    return date1.compare(date2) == .orderedAscending
                })

                let monthsSelector = MonthsSelector(months: months)
                strongSelf.monthsSelector = monthsSelector

                /// END OF FETCHING MONTHS

                onMainThread {
                    strongSelf.delegate?.acDeliveryDateViewModelDidFetchMonthsSelector(monthsSelector)
                    strongSelf.delegate?.acDeliveryDateViewModelDidFetchArbsVModel(uiModel)
                }
            }
        }
    }

    func switchToPrevMonth() {
        monthsSelector?.switchToPrevMonth()

        onMainThread {
            self.delegate?.acDeliveryDateViewModelDidFetchMonthsSelector(self.monthsSelector.required())
        }
    }

    func switchToNextMonth() {
        monthsSelector?.switchToNextMonth()

        onMainThread {
            self.delegate?.acDeliveryDateViewModelDidFetchMonthsSelector(self.monthsSelector.required())
        }
    }
}
