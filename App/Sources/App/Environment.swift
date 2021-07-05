//
//  Environment.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

public struct Environment {

    public static let environment: EnvironmentType = .stage

    public enum EnvironmentType: String {
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
        switch Self.environment {
        case .stage:
            return "https://strapi.staging.sparta.app"
        case .production:
            return "https://strapi.sparta.app"
        }
    }

    // DATA & SOCKETS URL's

    public static var baseDataURL: String {
        switch Self.environment {
        case .stage:
            return "https://backend.staging.sparta.app"
        case .production:
            return "https://backend.sparta.app"
        }
    }

    public static let socketBlenderURL = Self.baseDataURL + "/blender?regions=ARA,HOU"
    public static let socketLiveCurvesURL = Self.baseDataURL + "/socket/v2/curves"
    public static let socketArbsURL = Self.baseDataURL + "/socket/arbs?arbsmonths=6"

    // API KEY's

    public static let segmentAPIKey = "JuCj6uNsMFuqveOLtDfHvdhQeriCUqLk"
}
