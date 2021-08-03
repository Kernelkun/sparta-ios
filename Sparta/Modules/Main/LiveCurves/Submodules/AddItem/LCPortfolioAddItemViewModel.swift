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

protocol LCPortfolioAddItemViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didSuccessFetchList()
    func didSuccessAddItem()
}

class LCPortfolioAddItemViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LCPortfolioAddItemViewModelDelegate?
    var groups: [LCPortfolioAddItemViewModel.Group] = []

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

    private var initialLoadedGroups: [LCPortfolioAddItemViewModel.Group] = []
    private var searchRequest: String?

    // MARK: - Public methods

    func loadData() {
        isLoading = true

        let group = DispatchGroup()

        var groups: [LiveCurveProfileGroup] = []
        var items: [LiveCurveProfileProduct] = []

        group.enter()
        lcNetworkManager.fetchProducts { result in
            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                items = list
            }

            group.leave()
        }

        group.enter()
        lcNetworkManager.fetchProductGroups { result in
            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                groups = list
            }

            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }

            let groups = strongSelf.configureGroups(serverGroups: groups,
                                                    serverItems: items.sorted(by: { $0.shortName < $1.shortName }))
            strongSelf.groups = groups
            strongSelf.initialLoadedGroups = groups

            onMainThread {
                strongSelf.delegate?.didSuccessFetchList()
            }
        }
    }

    func search(query: String?) {

        func notify() {
            onMainThread {
                self.delegate?.didSuccessFetchList()
            }
        }

        guard let query = query, !query.isEmpty else {
            groups = initialLoadedGroups
            notify()
            return
        }

        searchRequest = query
        groups = initialLoadedGroups.filtered(by: searchRequest)

        notify()
    }

    func addProduct(_ item: LCPortfolioAddItemViewModel.Item) {
        guard let selectedProfile = liveCurvesSyncManager.profile else { return }

        isLoading = true

        lcNetworkManager.addProduct(portfolioId: selectedProfile.id, productId: item.id) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result, responseModel.model != nil {
                onMainThread {
                    strongSelf.delegate?.didSuccessAddItem()
                }
            } else {
                onMainThread {
                    strongSelf.delegate?.didCatchAnError("Portfolio.AddItems.Error.UnableToAdd".localized)
                }
            }

            strongSelf.isLoading = false
        }
    }

    // MARK: - Private methods

    private func configureGroups(serverGroups: [LiveCurveProfileGroup],
                                 serverItems: [LiveCurveProfileProduct]) -> [LCPortfolioAddItemViewModel.Group] {

        // groups

        var groups = serverGroups.compactMap { LCPortfolioAddItemViewModel.Group(group: $0) }

        // items

        serverItems.forEach { product in
            product.productGroups.forEach { group in
                if let indexOfGroup = groups.firstIndex(where: { group.id == $0.id }) {

                    func isActiveItem() -> Bool {
                        guard liveCurvesSyncManager.profile != nil else {
                            return true
                        }

                        return !liveCurvesSyncManager.profile!.liveCurves //swiftlint:disable:this force_unwrapping
                            .contains { $0.longName.lowercased() == product.longName.lowercased() }
                    }

                    var item = LCPortfolioAddItemViewModel.Item(item: product)
                    item.isActive = isActiveItem()

                    groups[indexOfGroup].items.append(item)
                }
            }
        }

        return groups.filter { !$0.items.isEmpty }
    }
}
