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
    case getPrimaryTradeAreas
    case getUserRoles

    // arbs favourite

    case getArbsFavouritesList
    case addArbToFavouritesList(parameters: Parameters)
    case deleteArbFromFavouritesList(id: Int)

    // blender favourite

    case getBlenderFavouritesList
    case addBlenderToFavouritesList(parameters: Parameters)
    case deleteBlenderFromFavouritesList(id: Int)
}

extension ProfileEndPoint: EndPointType {

    var baseURL: URL {
        switch self {
        case .getPrimaryTradeAreas, .getUserRoles, .getProfile:
            return Environment.baseDataURL.forcedURL

        case .updateUser:
            return Environment.baseAuthURL.forcedURL

        default:
            return Environment.baseAPIURL.forcedURL
        }
    }

    var path: String {
        switch self {
        case .updateUser(let id, _): return "/users/\(id)"
        case .getProfile: return "/users/me"
        case .getPrimaryTradeAreas: return "/primary-trade-areas"
        case .getUserRoles: return "/user-roles"

        // arbs favourites
        case .getArbsFavouritesList: return "/favorite-arbs"
        case .addArbToFavouritesList: return "/favorite-arbs"
        case .deleteArbFromFavouritesList(let id): return "/favorite-arbs/\(id)"

        // blender favourite

        case .getBlenderFavouritesList: return "favorite-grades"
        case .addBlenderToFavouritesList: return "/favorite-grades"
        case .deleteBlenderFromFavouritesList(let id): return "/favorite-grades/\(id)"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .deleteArbFromFavouritesList, .deleteBlenderFromFavouritesList: return .delete
        case .addArbToFavouritesList, .addBlenderToFavouritesList: return .post
        case .updateUser: return .put
        case .getProfile, .getPrimaryTradeAreas,
             .getUserRoles, .getArbsFavouritesList, .getBlenderFavouritesList: return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .deleteArbFromFavouritesList, .deleteBlenderFromFavouritesList:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)
            
        case .updateUser(_, let parameters), .addArbToFavouritesList(let parameters), .addBlenderToFavouritesList(let parameters):
            return .requestParametersAndHeaders(bodyParameters: parameters,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: parameters,
                                                additionHeaders: headersWithToken)

        case .getPrimaryTradeAreas, .getUserRoles, .getProfile,
             .getArbsFavouritesList, .getBlenderFavouritesList:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: headersWithToken)
        }
    }

    var header: HTTPHeaders? { nil }
}
