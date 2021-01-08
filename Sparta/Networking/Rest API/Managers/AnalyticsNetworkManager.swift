//
//  AnalyticsNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.12.2020.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class AnalyticsNetworkManager: BaseNetworkManager {

    // MARK: - Variables private

    private let router = NetworkRouter<AnalyticsEndPoint>()

    // MARK: - Public methods

    func fetchLiveCurves(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveCurve>>, SpartaError>>) {

        router.request(.getLiveCurves) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchArbsTable(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<Arb>>, SpartaError>>) {

        router.request(.getArbsTable) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
