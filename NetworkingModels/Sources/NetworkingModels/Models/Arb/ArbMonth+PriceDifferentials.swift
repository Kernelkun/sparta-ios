//
//  ArbMonth+PriceDifferentials.swift
//  
//
//  Created by Yaroslav Babalich on 01.02.2022.
//

import Foundation
import SwiftyJSON

public extension ArbMonth {

    struct PriceDifferentials: BackendModel {

        // MARK: - Public properties

        public let name: String
        public let value: ColoredNumber?

        // MARK: - Initialziers

        public init(json: JSON) {
            name = json["name"].stringValue

            if json["value"].dictionary != nil {
                value = ColoredNumber(json: json["value"])
            } else {
                value = nil
            }
        }
    }
}
