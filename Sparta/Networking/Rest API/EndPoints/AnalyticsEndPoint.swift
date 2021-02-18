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

    // arb

    case getArbsTable
    case updateArbUserTarget(parameters: Parameters)
    case deleteArbUserTarget(parameters: Parameters)

    // general

    case getLiveCurves
    case getFreightPorts
    case getFreightRoute(loadPortId: Int, dischargePortId: Int, date: String)
}

extension AnalyticsEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getLiveCurves: return "/livecurves"
        case .getArbsTable: return "/arbs/table"
        case .updateArbUserTarget: return "/arbs/user/target"
        case .deleteArbUserTarget: return "/arbs/user/target"
        case .getFreightPorts: return "/freight/loadports"
        case .getFreightRoute: return "/freight/route"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getLiveCurves, .getArbsTable, .getFreightPorts, .getFreightRoute: return .get
        case .updateArbUserTarget: return .post
        case .deleteArbUserTarget: return .delete
        }
    }

    var task: HTTPTask {
        switch self {
        case .updateArbUserTarget(let parameters):
            return .requestParametersAndHeaders(bodyParameters: parameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)

        case .deleteArbUserTarget(let parameters):
            return .requestParametersAndHeaders(bodyParameters: parameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)

        case .getLiveCurves:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)

        case .getArbsTable:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: ["arbsMonths": 6],
                                                additionHeaders: headersWithToken)

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
