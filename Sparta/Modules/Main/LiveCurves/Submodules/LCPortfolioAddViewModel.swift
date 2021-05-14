//
//  LCPortfolioAddViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol LCPortfolioAddViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didSuccessFetchList()
}

class LCPortfolioAddViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LCPortfolioAddViewModelDelegate?
    var categories: [Category] = []

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private let portfoliosManager = LiveCurvesPortfoliosManager()

    // MARK: - Public methods

    func loadData() {
        isLoading = true

        portfoliosManager.fetchLiveCurvesPortfolios { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                strongSelf.categories = list.compactMap { Category(category: $0) }

                onMainThread {
                    strongSelf.delegate?.didSuccessFetchList()
                }
            } else {
                onMainThread {
                    strongSelf.delegate?.didCatchAnError("Can't fetch live curves list")
                }
            }

            strongSelf.isLoading = false
        }
    }
}
