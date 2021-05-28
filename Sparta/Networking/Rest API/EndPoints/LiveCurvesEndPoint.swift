//
//  LiveCurvesEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum LiveCurvesEndPoint {
    case getLiveCurves
    case getPortfolios
    case getProductGroups
    case getProducts
    case addPortfolio(name: String)
    case addProduct(portfolioId: Int, productId: Int)
    case deletePortfolioItem(portfolioId: Int, liveCurveId: Int)
    case changePortfolioOrder(portfolioId: Int, parameters: Parameters)
}

extension LiveCurvesEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getLiveCurves: return "/livecurves"
        case .getPortfolios: return "/livecurves/portfolios"
        case .getProductGroups: return "/livecurves/productgroups"
        case .getProducts: return "/livecurves/products"
        case .addPortfolio: return "/livecurves/portfolios/"
        case .addProduct(let productId, _): return "/livecurves/portfolios/\(productId)/products"
        case .deletePortfolioItem(let portfolioId, let liveCurveId): return "/livecurves/portfolios/\(portfolioId)/products/\(liveCurveId)"
        case .changePortfolioOrder(let portfolioId, _): return "/livecurves/portfolios/\(portfolioId)/products/order"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getLiveCurves, .getPortfolios, .getProductGroups, .getProducts: return .get
        case .addPortfolio, .addProduct, .changePortfolioOrder: return .post
        case .deletePortfolioItem: return .delete
        }
    }

    var task: HTTPTask {
        switch self {
        case .getLiveCurves:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: ["includeQuarters": true, "includeYears": true],
                                                additionHeaders: headersWithToken)

        case .getPortfolios, .getProductGroups, .getProducts, .deletePortfolioItem:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)

        case .addPortfolio(let name):
            return .requestParametersAndHeaders(bodyParameters: ["name": name],
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)

        case .addProduct(_, let productId):
            return .requestParametersAndHeaders(bodyParameters: ["id": productId],
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)

        case .changePortfolioOrder(_, let parameters):
            return .requestParametersAndHeaders(bodyParameters: parameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
