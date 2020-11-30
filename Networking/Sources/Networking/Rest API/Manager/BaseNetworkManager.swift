//
//  BaseNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import NetworkingModels

public class BaseNetworkManager {
    
    enum NetworkResponse: String {
        case success
        case authenticationError = "You need to be authenticated first."
        case badRequest = "Bad request"
        case outdated = "The url you requested is outdated."
        case failed = "Network request failed."
        case noData = "Response returned with no data to decode."
        case unableToDecode = "We could not decode the response."
    }

    enum Result<String> {
        case success
        case failure(String)
    }
    
    // MARK: - Public methods
    
    // handle data result and handle default result
    
    static func handleResponse<T: BackendModel>(data: Data?,
                                                response: URLResponse?,
                                                error: Error?,
                                                modelPrimaryKey: String? = nil) -> Swift.Result<ResponseModel<T>, SpartaError> {
        
        if error != nil {
            return .failure(.invalidNetworkConnection)
        }
        
        if let response = response as? HTTPURLResponse {
            let result = self.handleNetworkResponse(response)
            
            guard let responseData = data else {
                return .failure(.custom(description: NetworkResponse.noData.rawValue))
            }
            
            NetworkLogger.log(responseData: responseData)
            
            let responseModel = ResponseModel<T>(json: JSON(responseData),
                                                 modelPrimaryKey: modelPrimaryKey)
            
            switch result {
            case .success:
                
                NetworkLogger.log(responseModel: responseModel)
                
                if responseModel.model != nil {
                    return .success(responseModel)
                } else {
                    return .failure(.unknown)
                }
                
            case .failure:
                return .failure(SpartaError(code: responseModel.statusCode ?? -1))
            }
        } else { return .failure(.unknown) }
    }
    
    static func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299: return .success
        case 400...422: return .failure(NetworkResponse.badRequest.rawValue)
        case 500...504: return .failure(NetworkResponse.authenticationError.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
    func handleResult<T: BackendModel>(data: Data?,
                                       response: URLResponse?,
                                       error: Error?,
                                       modelPrimaryKey: String? = nil) -> Swift.Result<ResponseModel<T>, SpartaError> {
        
        BaseNetworkManager.handleResponse(data: data, response: response, error: error, modelPrimaryKey: modelPrimaryKey)
    }
}
