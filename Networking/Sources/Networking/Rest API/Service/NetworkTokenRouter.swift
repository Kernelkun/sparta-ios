//
//  NetworkTokenRouter.swift
//  TalkGuard
//
//  Created by Yaroslav Babalich on 03.11.2020.
//

import Foundation
import SwiftyJSON

/*class NetworkTokenRouter<EndPoint: EndPointType>: NetworkRouter<EndPoint> {
    
    // MARK: - Variables private
    
    private var tokenTask: URLSessionTask?
    
    // MARK: - Override methods
    
    override func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        super.request(route) { data, response, error in
            if let response = response as? HTTPURLResponse {
                
                NetworkLogger.log(responseData: data)
                
                guard data != nil else {
                    completion(data, response, error)
                    return
                }
                
                if response.statusCode == 401 {
                    
                    self.refreshToken { isSuccess in
                        if isSuccess {
                            super.request(route, completion: completion)
                        } else { TalkGuard.instance.logout() }
                    }
                    
                    return
                } else {
                    completion(data, response, error)
                }
            } else { completion(data, response, error) }
        }
    }
    
    override func cancel() {
        super.cancel()
    }
    
    // MARK: - Private methods
    
    /*private func refreshToken(completion: @escaping BoolClosure) {
        let session = URLSession.shared
        
        let endPoint = TokenEndPoint()
        
        var request = URLRequest(url: endPoint.baseURL.appendingPathComponent(endPoint.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = endPoint.httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        NetworkLogger.log(request: request)
        
        tokenTask = session.dataTask(with: request, completionHandler: { data, response, error in

            let result: Swift.Result<ResponseModel<TokenResponse>, TalkGuardError> = BaseNetworkManager.handleResponse(data: data,
                                                                                                              response: response,
                                                                                                              error: error,
                                                                                                              modelPrimaryKey: "data")
            
            switch result {
            case .success(let responseModel) where responseModel.model != nil:
                
                TalkGuard.instance.saveTokenData(responseModel.model!)
                completion(true)
                
            case .success, .failure:
                completion(false)
            }
        })
        
        self.tokenTask?.resume()
    }*/
}*/
