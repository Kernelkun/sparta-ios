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

    // arb

    func fetchArbsTable(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<Arb>>, SpartaError>>) {

        router.request(.getArbsTable) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func updateArbUserTarget(_ userTarget: Double, for month: ArbMonth, completion: @escaping TypeClosure<Bool>) {

        let parameters: Parameters = ["gradeCode": month.gradeCode,
                                      "routeCode": month.routeCode,
                                      "monthName": month.name,
                                      "userTarget": userTarget]

        router.request(.updateArbUserTarget(parameters: parameters)) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func deleteArbUserTarget(for month: ArbMonth, completion: @escaping TypeClosure<Bool>) {

        let parameters: Parameters = ["gradeCode": month.gradeCode,
                                      "routeCode": month.routeCode,
                                      "monthName": month.name]

        router.request(.deleteArbUserTarget(parameters: parameters)) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
