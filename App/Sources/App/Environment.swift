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
        case dev
        case production

        public init(rawValue: String) {
            switch rawValue {
            case Self.stage.rawValue: self = .stage
            case Self.dev.rawValue: self = .dev
            case Self.production.rawValue: self = .production
            default: self = .stage
            }
        }
    }

    // REST API URL's

    public static var baseAuthURL: String {
        switch Self.environment {
        case .stage:
            return "https://strapi.staging.sparta.app"
        case .dev:
            return "https://strapi.staging.sparta.app"
        case .production:
            return "https://strapi.sparta.app"
        }
    }

    public static var baseAPIURL: String {
        switch Self.environment {
        case .stage:
            return "https://strapi.staging.sparta.app"
        case .dev:
            return "https://dev.sparta.app"
        case .production:
            return "https://strapi.sparta.app"
        }
    }

    // DATA & SOCKETS URL's

    public static var baseDataURL: String {
        switch Self.environment {
        case .stage:
            return "https://backend.staging.sparta.app"
        case .dev:
            return "https://backend.staging.sparta.app"
        case .production:
            return "https://backend.sparta.app"
        }
    }

    public static let socketBlenderURL = Self.baseDataURL + "/blender?regions=ARA,HOU&portfolioIds=1,2,3"
    public static let socketLiveCurvesURL = Self.baseDataURL + "/socket/v2/curves"
    public static let socketArbsURL = Self.baseDataURL + "/socket/arbs?arbsmonths=6&portfolioIds=1,2"

    public static func socketVisualisationsURL(dateRange: Visualisations.DateRange) -> String {
        Self.baseDataURL + "/socket/visualizations?dateRange=\(dateRange.rawValue)"
    }

    public static func socketLiveChartsURL(
        itemCode: String,
        tenorName: String,
        resolutions: [LiveChart.Resolution] = LiveChart.Resolution.allCases
    ) -> String {
        let tenorName = tenorName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let resolutionsString = resolutions.compactMap { $0.rawValue }.joined(separator: ",")
        return Self.baseDataURL + "/socket/livecharts?spartaCode=\(itemCode)&tenorName=\(tenorName)&resolution=\(resolutionsString)"
    }

    // API KEY's

    public static let segmentAPIKey = "JuCj6uNsMFuqveOLtDfHvdhQeriCUqLk"

    // LC chart

    public static var liveChartURL: String {
        switch Self.environment {
        case .stage, .dev:
            return "http://sparta-review-fix-core-10.s3-website-eu-west-1.amazonaws.com/standaloneChart/" //"https://staging.sparta.app/standaloneChart/"

        case .production:
            return "https://sparta.app/standaloneChart/"
        }
    }
    //"https://dev.sparta.app/standaloneChart/"
//    "http://sparta-review-ios-iframe-page.s3-website-eu-west-1.amazonaws.com/standaloneChart/"

    public static let avTradeChartURL = "http://sparta-review-ios-visualizations-iframe.s3-website-eu-west-1.amazonaws.com/visualizationsChart"
}
