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
    case getFreightPorts
    case getFreightRoute(loadPortId: Int, dischargePortId: Int, date: String)
}

extension AnalyticsEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getFreightPorts: return "/freight/loadports"
        case .getFreightRoute: return "/freight/route"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getFreightPorts, .getFreightRoute: return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .getFreightPorts:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)

        case .getFreightRoute(let loadPortId, let dischargePortId, let date):
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: ["loadPort": loadPortId,
                                                                "dischargePort": dischargePortId,
                                                                "selectDate": date],
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
