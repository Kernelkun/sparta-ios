//
//  MainTabsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 24.12.2020.
//

import Foundation
import NetworkingModels

class MainTabsViewModel {

    // MARK: - Public properties

    var isVisibleArbsBlock: Bool {
        currentUser?.arbs ?? false
    }

    var isVisibleBlenderBlock: Bool {
        currentUser?.blender ?? false
    }

    var isVisibleFreightBlock: Bool {
        currentUser?.freight ?? false
    }

    var isVisibleLivePricesBlock: Bool {
        currentUser?.liveprices ?? false
    }

    var isVisibleLiveChartsBlock: Bool {
        currentUser?.liveCharts ?? false
    }

    // MARK: - Private properties

    private var currentUser: User? { App.instance.currentUser }

    // MARK: - Public methods

    func sendAnalyticsEventMenuClicked(from: String, to: String) {
        let trackModel = AnalyticsManager.AnalyticsTrack(name: .menuClick, parameters: [
            "from": from,
            "name": to,
            "to": to
        ])

        AnalyticsManager.intance.track(trackModel)
    }
}
