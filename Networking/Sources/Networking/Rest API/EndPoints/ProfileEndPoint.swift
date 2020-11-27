//
//  ProfileEndPoint.swift
//  TalkGuard
//
//  Created by Yaroslav Babalich on 11.11.2020.
//

import Foundation

enum ProfileEndPoint {
    case options
    case callsRecords
    case markAsReadCallsRecords(recordsIds: [String])
    case logout
}

extension ProfileEndPoint: EndPointType {
    
    var baseURL: URL { Environment.baseAPIURL.forcedURL }
    
    var path: String {
        switch self {
        case .options: return "/api/options"
        case .callsRecords: return "/api/callrecs"
        case .markAsReadCallsRecords: return "/api/callrecs"
        case .logout: return "/api/logout"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .options, .callsRecords, .logout: return .get
        case .markAsReadCallsRecords: return .delete
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .options:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
            
        case .callsRecords:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: ["Authorization": TalkGuard.instance.token ?? ""])
            
        case .markAsReadCallsRecords(recordsIds: let callRecordsIds):
            return .requestParametersAndHeaders(bodyParameters: ["ids": callRecordsIds],
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: ["Authorization": TalkGuard.instance.token ?? ""])
            
        case .logout:
            return .request
        }
    }
    
    var header: HTTPHeaders? { return nil }
}

