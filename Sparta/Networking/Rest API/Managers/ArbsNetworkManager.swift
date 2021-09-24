//
//  ArbsNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.07.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class ArbsNetworkManager: BaseNetworkManager {

    // MARK: - Variables private

    private let router = NetworkRouter<ArbsEndPoint>()

    // MARK: - Public methods

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

        router.request(.updateArbUserTarget(parameters: parameters)) { _, response, _ in
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

        router.request(.deleteArbUserTarget(parameters: parameters)) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func fetchArbPlayground(for arb: Arb, completion: @escaping TypeClosure<Swift.Result<ResponseModel<ArbPlayground>, SpartaError>>) {

        let parameters: Parameters = ["gradeCode": arb.gradeCode,
                                      "routeCode": arb.routeCode,
                                      "arbsMonths": 6]

        router.request(.getArbPlayground(parameters: parameters)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
