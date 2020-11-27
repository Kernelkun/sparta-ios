//
//  AuthNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import UIKit
import SwiftyJSON

class AuthNetworkManager: BaseNetworkManager {
    
    // MARK: - Variables private
    
    private let router = NetworkRouter<AuthEndPoint>()
    
    // MARK: - Public methods
    
    func authentication(phoneNumber: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<RegistrationResponse>, TalkGuardError>>) {

        router.request(.authentication(phoneNumber: phoneNumber)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            
            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
    
    func activate(phoneNumber: String, code: Int, completion: @escaping TypeClosure<Swift.Result<ResponseModel<TokenResponse>, TalkGuardError>>) {

        router.request(.activation(phoneNumber: phoneNumber, code: code)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            
            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
