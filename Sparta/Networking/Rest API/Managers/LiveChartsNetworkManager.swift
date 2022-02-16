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

    private let router = NetworkRouter<LiveChartsEndPoint>()

    // MARK: - Public methods

    func fetchDateSelectors(code: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveChartDateSelector>>, SpartaError>>) {
        router.request(.getDateSelectors(code: code)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchHighlights(code: String, tenorCode: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveChartHighlight>>, SpartaError>>) {
        router.request(.getHighlights(code: code, tenorCode: tenorCode)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
