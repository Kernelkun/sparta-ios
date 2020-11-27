//
//  AuthEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation

enum AuthEndPoint {
    case authentication(phoneNumber: String)
    case activation(phoneNumber: String, code: Int)
}

extension AuthEndPoint: EndPointType {
    
    var baseURL: URL { Environment.baseAPIURL.forcedURL }
    
    var path: String {
        switch self {
        case .authentication(let phoneNumber): return "/api/auth/\(phoneNumber)"
        case .activation(let phoneNumber, _): return "/api/auth/\(phoneNumber)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .authentication: return .get
        case .activation: return .put
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .authentication:
            
            let urlParameters: Parameters? = TalkGuard.instance.environmentType == .development ? ["skipSMS": true] : nil
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .activation(_, let code):
            return .requestParameters(bodyParameters: ["code": code],
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        }
    }
    
    var header: HTTPHeaders? { return nil }
}
