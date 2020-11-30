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

public class AuthNetworkManager: BaseNetworkManager {
    
    // MARK: - Variables private
    
    private let router = NetworkRouter<AuthEndPoint>()

    // MARK: - Initializers

    public override init() {
        super.init()
    }

    // MARK: - Public methods
    
    public func auth(login: String, password: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<Login>, SpartaError>>) {

        let parameters: Parameters = [
            "identifier": login,
            "password": password
        ]

        router.request(.auth(parameters: parameters)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            
            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
