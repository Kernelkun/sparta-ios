//
//  ProfileNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2020.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class ProfileNetworkManager: BaseNetworkManager {

    // MARK: - Variables private

    private  let router = NetworkRouter<ProfileEndPoint>()

    // MARK: - Public methods

    func updateUser(id: Int, parameters: Parameters, completion: @escaping TypeClosure<Swift.Result<ResponseModel<User>, SpartaError>>) {

        router.request(.updateUser(id: id, parameters: parameters)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
