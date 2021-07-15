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

    private let liveCurvesSyncManager = App.instance.liveCurvesSyncManager
    private let lcNetworkManager = LiveCurvesNetworkManager()

    // MARK: - Public methods

    func createPortfolio() {
        guard let name = selectedName, !name.isEmpty else {
            delegate?.didCatchAnError("Portfolio.Add.Error.InvalidName".localized)
            return
        }

        isLoading = true

        lcNetworkManager.createPortfolio(name: name) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let profile = responseModel.model {

                strongSelf.liveCurvesSyncManager.addProfile(profile, makeActive: true)

                onMainThread {
                    strongSelf.delegate?.didSuccessCreatePortfolio()
                }
            } else {
                onMainThread {
                    strongSelf.delegate?.didCatchAnError("Portfolio.Add.Error.UnableToCreate".localized)
                }
            }

            strongSelf.isLoading = false
        }
    }
}
