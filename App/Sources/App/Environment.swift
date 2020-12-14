//
//  File.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

public struct Environment {

    public enum EnvironmentType: String {
        case development
        case stage
        case production

        public init(rawValue: String) {
            switch rawValue {
            case Self.stage.rawValue: self = .stage
            case Self.production.rawValue: self = .production
            default: self = .development
            }
        }
    }

    public static let baseAPIURL = "https://strapi.staging.sparta.app"
    public static let socketBlenderURL = "https://backend.staging.sparta.app/blender"
    public static let socketLiveCurvesURL = "https://backend.staging.sparta.app/feedprices"
}
