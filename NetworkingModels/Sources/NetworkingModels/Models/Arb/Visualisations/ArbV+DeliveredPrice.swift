//
//  ArbV+DeliveredPrice.swift
//  
//
//  Created by Yaroslav Babalich on 09.11.2021.
//

import Foundation
import SwiftyJSON

public extension ArbV {

    struct DeliveredPrice: BackendModel {
        //
        // MARK: - Public properties

        public let value: Double
        public let displayedValue: String

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            value = json["value"].doubleValue
            displayedValue = json["displayedValue"].stringValue
        }
    }
}
