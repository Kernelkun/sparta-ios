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

    // MARK: - Private properties

//    private let arbsNetworkManager = ArbsNetworkManager()

    // MARK: - Public methods

    func loadData() {
        /*arbsNetworkManager.fetchVArbsSelectorList(request: .init(type: .pricingCenter)) { [weak self] result in
            guard let strongSelf = self else { return }

            var selectors: [ArbV.Selector] = []
            if case let .success(responseModel) = result,
                let list = responseModel.model?.list {

                selectors = list
                strongSelf.chooseSelector(list.first.required())
            }

            onMainThread {
                strongSelf.delegate?.arbsPlaygroundPCViewModelDidFetchSelectors(selectors)
            }
        }*/
    }

    // MARK: - Private methods

    private func chooseSelector(_ arbVSelector: ArbV.Selector) {
        /*arbsNetworkManager.fetchVTableArbsInfo(request: .init(arbIds: arbVSelector.arbIds)) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
                let list = responseModel.model?.list {

                print(list)

            }
        }*/
    }
}

