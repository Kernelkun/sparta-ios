//
//  LiveChartsEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum LiveChartsEndPoint {
    case getDateSelectors(code: String)
}

extension LiveChartsEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getDateSelectors(let code): return "/livecharts/\(code)/dateselector"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getDateSelectors: return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .getDateSelectors:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}

