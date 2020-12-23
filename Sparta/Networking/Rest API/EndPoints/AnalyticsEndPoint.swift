//
//  AnalyticsEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.12.2020.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum AnalyticsEndPoint {
    case getLiveCurves
}

extension AnalyticsEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getLiveCurves: return "/livecurves"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getLiveCurves: return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .getLiveCurves:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}

