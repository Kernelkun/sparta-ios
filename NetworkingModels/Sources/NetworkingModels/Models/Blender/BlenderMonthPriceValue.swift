//
//  BlenderMonthPriceValue.swift
//  
//
//  Created by Yaroslav Babalich on 02.08.2021.
//

import Foundation
import SwiftyJSON

public extension BlenderMonth {

    struct PriceValue: BackendModel {

        //
        // MARK: - Public properties

        public let id: Int
        public let value: String

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            id = json["id"].intValue
            value = json["value"].stringValue
        }
    }
}
