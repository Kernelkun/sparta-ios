//
//  LiveCurvesPortfoliosEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum LiveCurvesPortfoliosEndPoint {
    case getPortfolios
}

extension LiveCurvesPortfoliosEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getPortfolios: return "/livecurves/portfolios"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getPortfolios: return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .getPortfolios:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
