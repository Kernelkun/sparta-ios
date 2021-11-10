//
//  ArbsEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.07.2021.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum ArbsEndPoint {
    case getArbsTable
    case updateArbUserTarget(parameters: Parameters)
    case deleteArbUserTarget(parameters: Parameters)
    case getArbPlayground(parameters: Parameters)
    case getArbVSelectorsList(parameters: NetworkParameters)
    case getArbsVTableInfo(parameters: NetworkParameters)
}

extension ArbsEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getArbsTable: return "/arbs/table"
        case .updateArbUserTarget: return "/arbs/user/target"
        case .deleteArbUserTarget: return "/arbs/user/target"
        case .getArbPlayground: return "/arbs/playground"
        case .getArbVSelectorsList: return "/arbs/visualizations/selector"
        case .getArbsVTableInfo: return "/arbs/visualisations/table"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getArbsTable, .getArbPlayground, .getArbVSelectorsList, .getArbsVTableInfo: return .get
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

        case .getArbsTable:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: ["arbsMonths": 6, "portfolioIds": "1,2"],
                                                additionHeaders: headersWithToken)

        case .getArbPlayground(let parameters):
            return .requestAnyAndHeaders(bodyParameters: nil,
                                         bodyEncoding: .urlEncoding,
                                         urlParameters: parameters,
                                         additionHeaders: headersWithToken)

        case .getArbVSelectorsList(let networkParameters), .getArbsVTableInfo(let networkParameters):
            return .requestParametersAndHeaders(bodyParameters: networkParameters.bodyParameters,
                                                bodyEncoding: networkParameters.bodyEncoding,
                                                urlParameters: networkParameters.urlParameters,
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
