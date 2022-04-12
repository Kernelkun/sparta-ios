//
//  ArbsComparationViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import Foundation
import NetworkingModels

class ArbsComparationViewModel: ArbsComparationViewModelInterface {

    // MARK: - Public properties

    weak var delegate: ArbsComparationViewModelDelegate?
    private(set) var arbsV: [ArbV] = []

    // MARK: - Private properties

    private let arbsNetworkManager = ArbsNetworkManager()

    // MARK: - Public methods

    func loadData() {
        arbsNetworkManager.fetchVArbsSelectorList(request: .init(type: .comparisonByDestination)) { [weak self] result in
            guard let strongSelf = self else { return }

            var selectors: [ArbV.Selector] = []
            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                selectors = list
                strongSelf.makeActiveArbVSelector(list.first.required())
            }

            onMainThread {
                strongSelf.delegate?.arbsComparationViewModelDidFetchDestinationSelectors(selectors)
            }
        }
    }

    func makeActiveArbVSelector(_ arbVSelector: ArbV.Selector) {
        arbsNetworkManager.fetchVTableArbsInfo(
            request: .init(arbIds: arbVSelector.arbIds)
        ) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let arbsV = responseModel.model?.list {

                strongSelf.arbsV = arbsV

                // fetching all months

                var allValues: [ArbV.Value] = []
                arbsV.forEach { allValues.append(contentsOf: $0.values) }

                var months: [ArbsComparationPCPUIModel.Month] = []
                allValues.forEach { value in
                    let month = ArbsComparationPCPUIModel.Month(title: value.deliveryMonth)
                    if !months.contains(month) {
                        months.append(month)
                    }
                }

                // end of fetching all months

                var uniqueIdentifier: Identifier<String>?
                let units = arbsV.first?.units ?? ""

                if let arbV = arbsV.first, let value = arbV.values.first {
                    uniqueIdentifier = arbV.uniqueIdentifier(from: value)
                }

                let model = ArbsComparationPCPUIModel(headers: months.compactMap { .init(month: $0, units: units) },
                                                      arbsV: arbsV.sorted { $0.order < $1.order },
                                                      selectedValueIdentifier: uniqueIdentifier)
                
                onMainThread {
                    strongSelf.delegate?.arbsComparationViewModelDidFetchArbsVModel(model)
                }
            }
        }
    }

    // MARK: - Private methods
}
