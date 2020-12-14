//
//  ProfileEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2020.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum ProfileEndPoint {
    case updateUser(id: Int, parameters: Parameters)
    case getProfile
    case getPhonePrefixes
    case getPrimaryTradeAreas
    case getUserRoles
}

extension ProfileEndPoint: EndPointType {

    var baseURL: URL { Environment.baseAPIURL.forcedURL }

    var path: String {
        switch self {
        case .updateUser(let id, _): return "/users/\(id)"
        case .getPhonePrefixes: return "/mobile-prefixes"
        case .getProfile: return "/users/me"
        case .getPrimaryTradeAreas: return "/primary-trade-areas"
        case .getUserRoles: return "/user-roles"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .updateUser: return .put
        case .getPhonePrefixes, .getProfile, .getPrimaryTradeAreas, .getUserRoles: return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .updateUser(_, let parameters):
            return .requestParametersAndHeaders(bodyParameters: parameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: parameters,
                                                additionHeaders: headersWithToken())

        case .getPrimaryTradeAreas, .getUserRoles, .getProfile, .getPhonePrefixes:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken())
        }
    }

    var header: HTTPHeaders? { nil }
}

extension ProfileEndPoint {

    func headersWithToken() -> HTTPHeaders {
        return ["Authorization": "Bearer \(App.instance.token ?? "")"]
    }
}
