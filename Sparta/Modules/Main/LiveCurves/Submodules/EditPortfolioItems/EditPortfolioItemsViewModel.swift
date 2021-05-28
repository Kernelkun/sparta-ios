//
//  EditPortfolioItemsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.05.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol EditPortfolioItemsViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didReceiveProfilesInfo(profiles: [LiveCurveProfileCategory], selectedProfile: LiveCurveProfileCategory?)
    func didUpdateDataSource(insertions: [IndexPath], removals: [IndexPath], updates: [IndexPath])
}

class EditPortfolioItemsViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: EditPortfolioItemsViewModelDelegate?
    var profiles: [LiveCurveProfileCategory] = []
    var selectedProfile: LiveCurveProfileCategory = .empty

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private let networkManager = LiveCurvesNetworkManager()

    // MARK: - Public methods

    func loadData() {
        isLoading = true

        networkManager.fetchPortfolios { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                if let firstProfile = list.first {
                    strongSelf.selectedProfile = firstProfile
                }

                strongSelf.profiles = list
            }

            onMainThread {
                strongSelf.isLoading = false
                strongSelf.delegate?.didReceiveProfilesInfo(profiles: strongSelf.profiles,
                                                            selectedProfile: strongSelf.selectedProfile)
            }
        }
    }

    func changeProfile(_ profile: LiveCurveProfileCategory) {
        selectedProfile = profile
        delegate?.didReceiveProfilesInfo(profiles: profiles, selectedProfile: selectedProfile)
    }

    func delete(item: LiveCurveProfileItem) {
        isLoading = true

        networkManager.deletePortfolioItem(portfolioId: selectedProfile.id, liveCurveId: item.id) { [weak self] result in
            guard let strongSelf = self else { return }

            if result {
                if let itemIndex = strongSelf.removeItem(item) {
                    onMainThread {
                        strongSelf.delegate?.didUpdateDataSource(insertions: [],
                                                                 removals: [IndexPath(row: itemIndex, section: 0)],
                                                                 updates: [])
                    }
                }
            } else {
            }
        }
    }

    func move(item: LiveCurveProfileItem, to index: Int) {
        moveItem(item, to: index)

        let parameters = selectedProfile.liveCurves.compactMap {
            ["id": $0.id, "order": selectedProfile.liveCurves.firstIndex(of: $0) ?? 0]
        }

        networkManager.changePortfolioItemsOrder(portfolioId: selectedProfile.id, orders: parameters) { _ in
        }
    }

    // MARK: - Private methods

    private func removeItem(_ item: LiveCurveProfileItem) -> Int? {
        guard let itemIndex = selectedProfile.liveCurves.firstIndex(of: item) else { return nil }

        let liveCurves = profiles
            .first { selectedProfile.id == $0.id }?.liveCurves
            .filter { $0.id != item.id } ?? []

        if let indexOfProfile = profiles.firstIndex(where: { selectedProfile.id == $0.id }) {
            profiles[indexOfProfile].liveCurves = liveCurves
            selectedProfile = profiles[indexOfProfile]
        }

        return itemIndex
    }

    private func moveItem(_ item: LiveCurveProfileItem, to index: Int) {
        var liveCurves = selectedProfile.liveCurves
        liveCurves.move(item, to: liveCurves.index(liveCurves.startIndex, offsetBy: index))

        if let indexOfProfile = profiles.firstIndex(where: { selectedProfile.id == $0.id }) {
            profiles[indexOfProfile].liveCurves = liveCurves
            selectedProfile.liveCurves = liveCurves
        }
    }
}
