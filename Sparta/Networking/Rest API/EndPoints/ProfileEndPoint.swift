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
}

extension ProfileEndPoint: EndPointType {

    var baseURL: URL { Environment.baseAPIURL.forcedURL }

    var path: String {
        switch self {
        case .updateUser(let id, _): return "/users/\(id)"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .updateUser: return .put
        }
    }

    var task: HTTPTask {
        switch self {
        case .updateUser(_, let parameters):
            return .requestParametersAndHeaders(bodyParameters: parameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: parameters,
                                                additionHeaders: ["Authorization": "Bearer \(App.instance.token ?? "")"])
        }
    }

    var header: HTTPHeaders? { nil }
}
