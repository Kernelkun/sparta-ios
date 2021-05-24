//
//  LCPortfolioAddViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 19.05.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol LCPortfolioAddViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didSuccessCreatePortfolio()
}

class LCPortfolioAddViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LCPortfolioAddViewModelDelegate?

    var selectedName: String?

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private let lcNetworkManager = LiveCurvesNetworkManager()

    // MARK: - Public methods

    func createPortfolio() {
        guard let name = selectedName, !name.isEmpty else {
            delegate?.didCatchAnError("Please enter valid portfolio name")
            return
        }

        isLoading = true

        lcNetworkManager.createPortfolio(name: name) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let model = responseModel.model {

                onMainThread {
                    strongSelf.delegate?.didSuccessCreatePortfolio()
                }
            } else {
                onMainThread {
                    strongSelf.delegate?.didCatchAnError("Something wrong happened with creating profile")
                }
            }

            strongSelf.isLoading = false
        }
    }
}
