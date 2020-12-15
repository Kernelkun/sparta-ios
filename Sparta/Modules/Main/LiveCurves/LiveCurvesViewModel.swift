//
//  LiveCurvesViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels

protocol LiveCurvesViewModelDelegate: class {

}

class LiveCurvesViewModel: NSObject, BaseViewModel {

    weak var delegate: LiveCurvesViewModelDelegate?

    // MARK: - Private properties

    private let liveCurvesSyncManager = App.instance.liveCurvesSyncManager

    // MARK: - Public methods

    func loadData() {
        liveCurvesSyncManager.delegate = self
        liveCurvesSyncManager.loadData()
    }
}

extension LiveCurvesViewModel: LiveCurvesSyncManagerDelegate {

    func liveCurvesSyncManagerDidFetch(liveCurves: [LiveCurve]) {

    }

    func liveCurvesSyncManagerDidReceive(liveCurves: LiveCurve) {

    }

    func liveCurvesSyncManagerDidReceiveUpdates(for liveCurves: LiveCurve) {

    }
}
