//
//  Environment.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

public struct Environment {

    private static let environement: EnvironmentType = .stage

    public enum EnvironmentType: String {
//        case development
        case stage
        case production

        public init(rawValue: String) {
            switch rawValue {
            case Self.stage.rawValue: self = .stage
            case Self.production.rawValue: self = .production
            default: self = .stage
            }
        }
    }

    // REST API URL's

    public static var baseAPIURL: String {
        switch Self.environement {
        case .stage:
            return "https://strapi.staging.sparta.app"
        case .production:
            return "https://strapi.sparta.app"
        }
    }

    // SOCKETS URL's

    private static var baseSocketsURL: String {
        switch Self.environement {
        case .stage:
            return "https://backend.staging.sparta.app"
        case .production:
            return "https://backend.sparta.app"
        }
    }

    public static let socketBlenderURL = Self.baseSocketsURL + "/blender"
    public static let socketLiveCurvesURL = Self.baseSocketsURL + "/feedprices"
}
