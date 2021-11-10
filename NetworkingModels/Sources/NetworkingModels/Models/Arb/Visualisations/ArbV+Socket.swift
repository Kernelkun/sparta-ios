//
//  ArbV+Socket.swift
//  
//
//  Created by Yaroslav Babalich on 02.11.2021.
//

import Foundation
import SwiftyJSON

public extension ArbV {

    struct Socket: BackendModel {
        //
        // MARK: - Public properties

        public let arbId: Int
        public let loadMonth: String
        public let deliveredPrice: String
        public let margins: [ArbV.Margin]

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            arbId = json["arbId"].intValue
            loadMonth = json["loadMonth"].stringValue
            deliveredPrice = json["deliveredPrice"].stringValue
            margins = json["margins"].arrayValue.compactMap { ArbV.Margin(json: $0) }
        }
    }
}
