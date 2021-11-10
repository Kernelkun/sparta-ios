//
//  ArbVMargin.swift
//  
//
//  Created by Yaroslav Babalich on 02.11.2021.
//

import Foundation
import SwiftyJSON

public extension ArbV {

    struct Margin: BackendModel {
        //
        // MARK: - Public properties

        public let type: String
        public let price: ColoredNumber

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            type = json["type"].stringValue

            let value = json["displayedValue"].stringValue
            let color = json["color"].stringValue
            price = ColoredNumber(value: value, color: color)
        }
    }
}
