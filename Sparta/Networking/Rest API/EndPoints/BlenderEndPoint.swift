//
//  BlenderEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.07.2021.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum BlenderEndPoint {
    case getBlenderTable
    case changePortfolioOrder(regionId: Int, parameters: [Parameters])
    case deleteCustomBlender(gradeCode: String)
}

extension BlenderEndPoint: EndPointType {

    var baseURL: URL { Environment.baseDataURL.forcedURL }

    var path: String {
        switch self {
        case .getBlenderTable: return "/blender/table"
        case .changePortfolioOrder(let regionId, _): return "/blender/customization/grades/\(regionId)/order"
        case .deleteCustomBlender: return "/blender/customization/grades"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getBlenderTable: return .get
        case .changePortfolioOrder: return .post
        case .deleteCustomBlender: return .delete
        }
    }

    var task: HTTPTask {
        switch self {
        case .getBlenderTable:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: ["regions": "ARA,HOU"],
                                                additionHeaders: headersWithToken)

        case .changePortfolioOrder(_, let parameters):
            return .requestAnyAndHeaders(bodyParameters: parameters,
                                         bodyEncoding: .jsonEncoding,
                                         urlParameters: nil,
                                         additionHeaders: headersWithToken)

        case .deleteCustomBlender(let gradeCode):
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: ["gradeCodes": gradeCode],
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
