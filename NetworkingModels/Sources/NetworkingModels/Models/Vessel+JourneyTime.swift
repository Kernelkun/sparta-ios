//
//  Vessel+JourneyTime.swift
//  
//
//  Created by Yaroslav Babalich on 11.05.2022.
//

import Foundation
import SwiftyJSON

public extension Vessel {

    struct JourneyTime: BackendModel, Hashable {
        //
        // MARK: - Public properties

        public let days: Int
        public let hours: Int

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            days = json["days"].intValue
            hours = json["hours"].intValue
        }
    }
}
