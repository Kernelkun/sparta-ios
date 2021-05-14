//
//  LiveCurvesPortfoliosManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class LiveCurvesPortfoliosManager: BaseNetworkManager {

    // MARK: - Variables private

    private let router = NetworkRouter<LiveCurvesPortfoliosEndPoint>()

    // MARK: - Public methods

    func fetchLiveCurvesPortfolios(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveCurveProfileCategory>>, SpartaError>>) {

        router.request(.getPortfolios) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
