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
            case popupShown
            case changePassword

            var trackServerName: String {
                switch self {
                case .menuClick:
                    return "Click on menu"

                case .popupShown:
                    return "Popup shown"

                case .changePassword:
                    return "Change password"
                }
            }
        }

        // MARK: - Public variables

        let name: EventName
        let parameters: Parameters
    }
}
