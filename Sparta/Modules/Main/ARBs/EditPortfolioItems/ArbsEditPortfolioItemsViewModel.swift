//
//  ArbsEditPortfolioItemsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.11.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol ArbsEditPortfolioItemsViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didReceiveProfilesInfo(profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?)
    func didUpdateDataSource(insertions: [IndexPath], removals: [IndexPath], updates: [IndexPath])
}

class ArbsEditPortfolioItemsViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbsEditPortfolioItemsViewModelDelegate?
    var portfolios: [ArbProfileCategory] = []
    var selectedPortfolio: ArbProfileCategory!

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private lazy var arbsSyncManager = App.instance.arbsSyncManager
    private let networkManager = ArbsNetworkManager()

    // MARK: - Public methods

    func loadData() {
        portfolios = arbsSyncManager.portfolios
        selectedPortfolio = arbsSyncManager.portfolio

        onMainThread {
            self.delegate?.didReceiveProfilesInfo(profiles: self.portfolios,
                                                  selectedProfile: self.selectedPortfolio)
        }
    }

    func changePortfolio(_ portfolio: ArbProfileCategory) {
        selectedPortfolio = portfolio
        delegate?.didReceiveProfilesInfo(profiles: portfolios, selectedProfile: selectedPortfolio)
    }

    func move(item: Arb, to index: Int) {
        let oldArbs = selectedPortfolio.arbs

        moveItem(item, to: index)

        var parameters: [Parameters] = []
        for item in oldArbs {
            parameters.append(["id": oldArbs.firstIndex(of: item) ?? 0, "order": selectedPortfolio.arbs.firstIndex(of: item) ?? 0])
        }

        print(parameters.debugDescription)

        networkManager.changePortfolioItemsOrder(request: .init(portfolio: selectedPortfolio.portfolio,
                                                                orders: parameters), completion: { _ in })
    }

    // MARK: - Private methods

    private func moveItem(_ item: Arb, to index: Int) {
        var items = selectedPortfolio.arbs
        items.move(item, to: items.index(items.startIndex, offsetBy: index))

        for (index, _) in items.enumerated() {
            items[index].order = index
        }

        if let indexOfProfile = portfolios.firstIndex(of: selectedPortfolio) {
            portfolios[indexOfProfile].arbs = items
            selectedPortfolio.arbs = items
        }
    }
}
