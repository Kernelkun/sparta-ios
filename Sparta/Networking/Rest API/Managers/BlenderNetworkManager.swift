//
//  BlenderNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.07.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class BlenderNetworkManager: BaseNetworkManager {

    // MARK: - Variables private

    private let router = NetworkRouter<BlenderEndPoint>()

    // MARK: - Public methods

    func fetchBlenderTable(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<Blender>>, SpartaError>>) {
        router.request(.getBlenderTable) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func changePortfolioItemsOrder(region: BlenderRegion, orders: [Parameters], completion: @escaping BoolClosure) {
        router.request(.changePortfolioOrder(regionName: region.name.uppercased(), parameters: orders)) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func deleteCustomBlender(gradeCode: String, completion: @escaping BoolClosure) {
        router.request(.deleteCustomBlender(gradeCode: gradeCode)) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
