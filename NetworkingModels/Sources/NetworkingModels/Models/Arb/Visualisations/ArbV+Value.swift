//
//  ArbV+Value.swift
//  
//
//  Created by Yaroslav Babalich on 09.11.2021.
//

import Foundation
import SwiftyJSON

public extension ArbV {

    struct Value: BackendModel {
        //
        // MARK: - Public properties

        public let loadMonth: String
        public let deliveryMonth: String
        public let displayedWindow: String
        public let deliveredPrice: ArbV.DeliveredPrice
        public let margins: [ArbV.Margin]

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            loadMonth = json["loadMonth"].stringValue
            deliveryMonth = json["deliveryMonth"].stringValue
            displayedWindow = json["displayedWindow"].stringValue
            deliveredPrice = DeliveredPrice(json: json["deliveredPrice"])
            margins = json["margins"].arrayValue.compactMap { ArbV.Margin(json: $0) }
        }
    }
}
