//
//  AuthEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation
import App
import SpartaHelpers

enum AuthEndPoint {
    case auth(parameters: Parameters)
}

extension AuthEndPoint: EndPointType {
    
    var baseURL: URL { Environment.baseAPIURL.forcedURL }
    
    var path: String {
        switch self {
        case .auth: return "/auth/local"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .auth: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .auth(parameters: let parameters):
            return .requestParameters(bodyParameters: parameters,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        }
    }
    
    var header: HTTPHeaders? { return nil }
}
