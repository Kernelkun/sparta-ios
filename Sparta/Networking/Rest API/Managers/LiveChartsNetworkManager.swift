//
//  LiveChartsNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class LiveChartsNetworkManager: BaseNetworkManager {

    // MARK: - Variables private

    private let router = NetworkRouter<LiveCurvesEndPoint>()

    // MARK: - Public methods

    func fetchDateSelectors(code: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveCurve>>, SpartaError>>) {
        router.request(.getLiveCurves) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

//            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
