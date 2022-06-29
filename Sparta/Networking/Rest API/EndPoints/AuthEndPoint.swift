//
//  AuthEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum AuthEndPoint {
    case auth(parameters: Parameters)
    case forgotPassword(email: String)
}

extension AuthEndPoint: EndPointType {
    
    var baseURL: URL { Environment.baseAuthURL.forcedURL }
    
    var path: String {
        switch self {
        case .auth: return "/auth/local"
        case .forgotPassword: return "/auth/forgot-password"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .auth, .forgotPassword: return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .auth(parameters: let parameters):
            return .requestParameters(bodyParameters: parameters,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)

        case .forgotPassword(email: let email):
            return .requestParameters(bodyParameters: ["email": email],
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        }
    }
    
    var header: HTTPHeaders? { return nil }
}
