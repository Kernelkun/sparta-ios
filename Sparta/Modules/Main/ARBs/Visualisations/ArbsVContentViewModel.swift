//
//  ArbsVContentViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.03.2022.
//

import Foundation

class ArbsVContentViewModel: ArbsVContentViewModelInterface {

    // MARK: - Private properties

    private let arbsSyncManager: ArbsVisSyncInterface = ArbsVisSyncManager()

    // MARK: - Public methods

    func startLoadDataForPC() {
        arbsSyncManager.start(dateRange: .month)
    }

    func startLoadDataForAC() {
        arbsSyncManager.start(dateRange: .semidecade)
    }

    func stopLoadData() {

    }

}
