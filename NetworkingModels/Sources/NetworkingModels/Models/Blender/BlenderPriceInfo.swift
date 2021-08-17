//
//  BlenderPriceInfo.swift
//  
//
//  Created by Yaroslav Babalich on 02.08.2021.
//

import Foundation
import SwiftyJSON

public extension Blender {

    struct PriceInfo: BackendModel {

        //
        // MARK: - Public properties

        public let id: Int
        public let order: Int
        public let name: String
        public let unit: String

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            id = json["id"].intValue
            order = json["order"].intValue
            name = json["name"].stringValue
            unit = json["unit"].stringValue
        }
    }
}
