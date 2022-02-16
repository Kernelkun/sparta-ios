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
    case getHighlights(code: String, tenorCode: String)
}

extension LiveChartsEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getDateSelectors(let code): return "/livecharts/\(code)/dateselector"
        case .getHighlights: return "/data-warehouse/live-charts/highlights"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getDateSelectors, .getHighlights: return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .getDateSelectors:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)

        case .getHighlights(let code, let tenorCode):
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: ["spartaCode": code, "tenorName": tenorCode],
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
