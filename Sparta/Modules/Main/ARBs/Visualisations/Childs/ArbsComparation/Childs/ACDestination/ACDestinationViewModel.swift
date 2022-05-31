//
//  ACDestinationViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.04.2022.
//

import Foundation
import NetworkingModels

class ACDestinationViewModel: ACDestinationViewModelInterface {

    // MARK: - Public properties

    weak var delegate: ACDestinationViewModelDelegate?
    private(set) var arbsV: [ArbV] = []

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.acDestinationViewModelDidChangeLoadingState(self.isLoading)
            }
        }
    }

    private let arbsNetworkManager = ArbsNetworkManager()
    private var selectedModel: ArbsComparationPCPUIModel?

    // MARK: - Public methods

    func loadData() {
        isLoading = true

        arbsNetworkManager.fetchVArbsSelectorList(request: .init(type: .comparisonByDestination)) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false

            var selectors: [ArbV.Selector] = []
            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                selectors = list
                strongSelf.makeActiveArbVSelector(list.first.required())
            }

            onMainThread {
                strongSelf.delegate?.acDestinationViewModelDidFetchDestinationSelectors(selectors)
            }
        }
    }

    func makeActiveArbVSelector(_ arbVSelector: ArbV.Selector) {
        isLoading = true

        arbsNetworkManager.fetchVTableArbsInfo(
            request: .init(arbIds: arbVSelector.arbIds)
        ) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false

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

                let units = arbsV.first?.units ?? ""

                var activeModel: ArbsComparationPCPUIModel.Active!

                if let arbV = arbsV.first, let value = arbV.values.first {
                    activeModel = ArbsComparationPCPUIModel.Active(arbV: arbV, arbVValue: value)
                }

                let model = ArbsComparationPCPUIModel(headers: months.compactMap { .init(month: $0, units: units) },
                                                      arbsV: arbsV.sorted { $0.order < $1.order },
                                                      active: activeModel)

                strongSelf.selectedModel = model

                onMainThread {
                    strongSelf.delegate?.acDestinationViewModelDidFetchArbsVModel(model)
                }
            }
        }
    }

    func makeActiveModel(_ activeModel: ArbsComparationPCPUIModel.Active) {
        self.selectedModel?.active = activeModel

        onMainThread {
            self.delegate?.acDestinationViewModelDidChangeActiveArbVValue(self.selectedModel.required())
        }
    }
}
