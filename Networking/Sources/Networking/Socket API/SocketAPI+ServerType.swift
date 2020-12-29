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

        case blender
        case liveCurves
    }
}

extension SocketAPI.Server {

    var link: URL {
        switch self {
        case .blender:
            return Environment.socketBlenderURL.forcedURL
        case .liveCurves:
            return Environment.socketLiveCurvesURL.forcedURL
        }
    }
}
