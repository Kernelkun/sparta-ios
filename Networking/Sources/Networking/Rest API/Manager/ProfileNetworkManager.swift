//
//  ProfileNetworkManager.swift
//  TalkGuard
//
//  Created by Yaroslav Babalich on 11.11.2020.
//

import UIKit
import SwiftyJSON

class ProfileNetworkManager: BaseNetworkManager {
    
    // MARK: - Variables private
    
    private let router = NetworkTokenRouter<ProfileEndPoint>()
    
    // MARK: - Public methods
    
    func fetchOptions(completion: @escaping TypeClosure<Swift.Result<ResponseModel<OptionsResponse>, TalkGuardError>>) {

        router.request(.options) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            
            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
    
    func logout() {
        
        router.request(.logout) { _, _, _ in
            
        }
    }
}
