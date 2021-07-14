//
//  BlenderEditPortfolioItemsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.07.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol BlenderEditPortfolioItemsViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didReceiveProfilesInfo(profiles: [BlenderProfileCategory], selectedProfile: BlenderProfileCategory?)
    func didUpdateDataSource(insertions: [IndexPath], removals: [IndexPath], updates: [IndexPath])
}

class BlenderEditPortfolioItemsViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: BlenderEditPortfolioItemsViewModelDelegate?
    var profiles: [BlenderProfileCategory] = []
    var selectedProfile: BlenderProfileCategory = BlenderProfileCategory(region: .ara)

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private lazy var blendersSyncManager = App.instance.blenderSyncManager
    private let networkManager = BlenderNetworkManager()

    // MARK: - Public methods

    func loadData() {
        profiles = blendersSyncManager.profiles.arrayValue
        selectedProfile = profiles.first!

        onMainThread {
            self.delegate?.didReceiveProfilesInfo(profiles: self.profiles,
                                                  selectedProfile: self.selectedProfile)
        }

        /*networkManager.fetchBlenderTable { [weak self] result in
         guard let strongSelf = self else { return }

         if case let .success(responseModel) = result,
         let list = responseModel.model?.list {

         var araCategory = BlenderProfileCategory(region: .ara)
         var houCategory = BlenderProfileCategory(region: .hou)

         strongSelf.profiles = [araCategory, houCategory]
         strongSelf.selectedProfile = strongSelf.profiles.first { $0.region == $0.region }

         araCategory.blenders = list.filter { $0.loadRegion == .ara }
         houCategory.blenders = list.filter { $0.loadRegion == .hou }


         }
         }*/
    }

    func changeProfile(_ profile: BlenderProfileCategory) {
        selectedProfile = profile
        delegate?.didReceiveProfilesInfo(profiles: profiles, selectedProfile: selectedProfile)
    }

    func delete(item: Blender) {
        isLoading = true

        networkManager.deleteCustomBlender(gradeCode: item.gradeCode) { [weak self] result in
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

    func move(item: Blender, to index: Int) {
        moveItem(item, to: index)

        let parameters = selectedProfile.blenders.compactMap {
            ["gradeCode": $0.gradeCode, "position": selectedProfile.blenders.firstIndex(of: $0) ?? 0]
        }

        networkManager.changePortfolioItemsOrder(region: selectedProfile.region, orders: parameters, completion: { _ in })
    }

    // MARK: - Private methods

    private func removeItem(_ item: Blender) -> Int? {
        guard let itemIndex = selectedProfile.blenders.firstIndex(of: item) else { return nil }

        let blenders = profiles
            .first(where: { $0.region == selectedProfile.region })?.blenders
            .filter { $0.gradeCode != item.gradeCode } ?? []

        if let indexOfProfile = profiles.firstIndex(of: selectedProfile) {
            profiles[indexOfProfile].blenders = blenders
            selectedProfile = profiles[indexOfProfile]
        }

        return itemIndex
    }

    private func moveItem(_ item: Blender, to index: Int) {
        var blenders = selectedProfile.blenders
        blenders.move(item, to: blenders.index(blenders.startIndex, offsetBy: index))

        if let indexOfProfile = profiles.firstIndex(of: selectedProfile) {
            profiles[indexOfProfile].blenders = blenders
            selectedProfile.blenders = blenders
        }
    }
}
