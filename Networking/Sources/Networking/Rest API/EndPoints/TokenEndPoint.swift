//
//  TokenEndPoint.swift
//  TalkGuard
//
//  Created by Yaroslav Babalich on 03.11.2020.
//

import Foundation

struct TokenEndPoint: EndPointType {
    
    var baseURL: URL { Environment.baseAPIURL.forcedURL }
    
    var path: String { "/api/auth/refresh_token/\(TalkGuard.instance.refreshToken ?? "")" }
    
    var httpMethod: HTTPMethod { .get }
    
    var task: HTTPTask { .request }
    
    var header: HTTPHeaders? { nil }
}
