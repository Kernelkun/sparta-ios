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
        public let deliveryWindow: String
        public let deliveredPrice: ArbV.DeliveredPrice
        public let margins: [ArbV.Margin]

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            loadMonth = json["loadMonth"].stringValue
            deliveryMonth = json["deliveryMonth"].stringValue
            deliveryWindow = json["deliveryWindow"].stringValue
            deliveredPrice = DeliveredPrice(json: json["deliveredPrice"])
            margins = json["margins"].arrayValue.compactMap { ArbV.Margin(json: $0) }
        }
    }
}

extension ArbV.Value: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.loadMonth == rhs.loadMonth
        && lhs.deliveryMonth == rhs.deliveryMonth
        && lhs.deliveryWindow == rhs.deliveryWindow
    }
}
