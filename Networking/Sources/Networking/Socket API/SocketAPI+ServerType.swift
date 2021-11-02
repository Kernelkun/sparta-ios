//
//  SocketAPI+Server.swift
//  
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import Foundation
import App

public extension SocketAPI {

    enum Server: String, CaseIterable {
        case unknown
        case blender
        case liveCurves
        case arbs
        case visualisations
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
        default:
            return nil
        }
    }
}
