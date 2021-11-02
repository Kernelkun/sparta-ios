//
//  ArbsPlaygroundPCViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import Foundation

class ArbsPlaygroundPCViewModel: ArbsPlaygroundPCViewModelInterface {

    // MARK: - Public properties

    weak var delegate: ArbsPlaygroundPCViewModelDelegate?

    // MARK: - Private properties

    private let arbsNetworkManager = ArbsNetworkManager()

    // MARK: - Public methods

    func loadData() {
        arbsNetworkManager.fetchVArbsSelectorList(request: .init(type: .pricingCenter)) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
                let list = responseModel.model?.list {
            }
        }
    }
}
