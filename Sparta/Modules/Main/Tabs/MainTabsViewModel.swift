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
        currentUser?.arbs ?? true
    }

    var isVisibleBlenderBlock: Bool {
        currentUser?.blender ?? true
    }

    var isVisibleFreightBlock: Bool {
        currentUser?.freight ?? true
    }

    var isVisibleLivePricesBlock: Bool {
        currentUser?.liveprices ?? true
    }

    // MARK: - Private properties

    private var currentUser: User? { App.instance.currentUser }

}
