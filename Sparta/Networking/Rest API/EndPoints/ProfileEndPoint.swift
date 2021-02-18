//
//  ProfileEndPoint.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2020.
//

import Foundation
import SpartaHelpers
import Networking
import App

enum ProfileEndPoint {
    case updateUser(id: Int, parameters: Parameters)
    case getProfile
    case getPhonePrefixes
    case getPrimaryTradeAreas
    case getUserRoles

    // arbs favourite

    case getArbsFavouritesList
    case addArbToFavouritesList(parameters: Parameters)
    case deleteArbFromFavouritesList(id: Int)
}

extension ProfileEndPoint: EndPointType {

    var baseURL: URL { Environment.baseAPIURL.forcedURL }

    var path: String {
        switch self {
        case .updateUser(let id, _): return "/users/\(id)"
        case .getPhonePrefixes: return "/mobile-prefixes"
        case .getProfile: return "/users/me"
        case .getPrimaryTradeAreas: return "/primary-trade-areas"
        case .getUserRoles: return "/user-roles"

        // favourites
        case .getArbsFavouritesList: return "/favorite-arbs"
        case .addArbToFavouritesList: return "/favorite-arbs"
        case .deleteArbFromFavouritesList(let id): return "/favorite-arbs/\(id)"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .deleteArbFromFavouritesList: return .delete
        case .addArbToFavouritesList: return .post
        case .updateUser: return .put
        case .getPhonePrefixes, .getProfile, .getPrimaryTradeAreas,
             .getUserRoles, .getArbsFavouritesList: return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .deleteArbFromFavouritesList:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)
            
        case .updateUser(_, let parameters), .addArbToFavouritesList(let parameters):
            return .requestParametersAndHeaders(bodyParameters: parameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: parameters,
                                                additionHeaders: headersWithToken)

        case .getPrimaryTradeAreas, .getUserRoles, .getProfile, .getPhonePrefixes, .getArbsFavouritesList:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
