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
    case getArbsPortfolios(parameters: NetworkParameters)
    case getArbsTable(parameters: NetworkParameters)
    case changePortfolioOrder(request: UpdateArbsPIOrderRequest)
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
        case .getArbsPortfolios: return "/arbs/portfolios"
        case .getArbsTable: return "/arbs/portfolios/tableFull"
        case .updateArbUserTarget: return "/arbs/user/target"
        case .deleteArbUserTarget: return "/arbs/user/target"
        case .getArbPlayground: return "/arbs/playground"
        case .changePortfolioOrder(let request): return "/arbs/portfolios/\(request.portfolio.id)/destinations/order"
        case .getArbVSelectorsList: return "/arbs/visualizations/selector"
        case .getArbsVTableInfo: return "/arbs/portfolios/table"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getArbsTable, .getArbPlayground, .getArbsPortfolios,
                .getArbVSelectorsList, .getArbsVTableInfo: return .get
        case .updateArbUserTarget: return .post
        case .deleteArbUserTarget: return .delete
        case .changePortfolioOrder: return .put
        }
    }

    var task: HTTPTask {
        switch self {
        case .getArbsPortfolios(let parameters), .getArbsTable(let parameters),
                .getArbVSelectorsList(let parameters), .getArbsVTableInfo(let parameters):
            return .requestParametersAndHeaders(bodyParameters: parameters.bodyParameters,
                                                bodyEncoding: parameters.bodyEncoding,
                                                urlParameters: parameters.urlParameters,
                                                additionHeaders: headersWithToken)

        case .changePortfolioOrder(let request):
            return .requestParametersAndHeaders(bodyParameters: request.bodyParameters,
                                                bodyEncoding: request.bodyEncoding,
                                                urlParameters: request.urlParameters,
                                                additionHeaders: headersWithToken)

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

        case .getArbPlayground(let parameters):
            return .requestAnyAndHeaders(bodyParameters: nil,
                                         bodyEncoding: .urlEncoding,
                                         urlParameters: parameters,
                                         additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
