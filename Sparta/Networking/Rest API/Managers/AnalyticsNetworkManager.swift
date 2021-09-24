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

    func fetchFreightPorts(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<FreightPort>>, SpartaError>>) {

        router.request(.getFreightPorts) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchFreightRoute(loadPortId: Int,
                           dischargePortId: Int,
                           selectedDate: String,
                           completion: @escaping TypeClosure<Swift.Result<ResponseModel<FreightRoute>, SpartaError>>) {

        router.request(.getFreightRoute(loadPortId: loadPortId,
                                        dischargePortId: dischargePortId,
                                        date: selectedDate)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
