//
//  AuthNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class AuthNetworkManager: BaseNetworkManager {
    
    // MARK: - Variables private
    
    private  let router = NetworkRouter<AuthEndPoint>()

    // MARK: - Public methods
    
    func auth(login: String, password: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<Login>, SpartaError>>) {

        let parameters: Parameters = [
            "identifier": login,
            "password": password
        ]

        router.request(.auth(parameters: parameters)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            
            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func forgotPassword(for email: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<EmptyResponseModel>, SpartaError>>) {

        router.request(.forgotPassword(email: email)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
