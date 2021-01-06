//
//  AnalyticsManager+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.01.2021.
//

import Foundation

// base analytics models

extension AnalyticsManager {

    typealias Parameters = [String: String]

    struct AnalyticsTrack {

        enum EventName {
            case menuClick

            var trackServerName: String {
                switch self {
                case .menuClick:
                    return "Click on menu"
                }
            }
        }

        // MARK: - Public variables

        let name: EventName
        let parameters: Parameters
    }
}
