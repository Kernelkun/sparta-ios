//
//  SocketAPI+Server.swift
//  
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import Foundation
import App

public extension SocketAPI {

    enum Server: Hashable, CaseIterable {
        case unknown
        case blender
        case liveCurves
        case arbs
        case visualisations
        case liveCharts(itemCode: String, tenorName: String, resolution: [Environment.LiveChart.Resolution])

        // MARK: - Public variables

        public static var allCases: [SocketAPI.Server] {
            return [.unknown, .blender, .liveCurves, .arbs, .liveCharts(itemCode: "", tenorName: "", resolution: [])]
        }

        public var rawValue: String {
            link?.absoluteString ?? "Unknown url"
        }
    }
}

extension SocketAPI.Server {

    var link: URL? {
        switch self {
        case .blender:
            return Environment.socketBlenderURL.forcedURL
        case .liveCurves:
            return Environment.socketLiveCurvesURL.forcedURL
        case .arbs:
            return Environment.socketArbsURL.forcedURL
        case .visualisations:
            return Environment.socketVisualisationsURL.forcedURL
        case .liveCharts(let itemCode, let tenorName, let resolution):
            return Environment.socketLiveChartsURL(
                itemCode: itemCode,
                tenorName: tenorName,
                resolutions: resolution
            ).forcedURL
        default:
            return nil
        }
    }
}
