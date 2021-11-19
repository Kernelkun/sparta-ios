//
//  Arb+Portfolio.swift
//  
//
//  Created by Yaroslav Babalich on 30.09.2021.
//

import Foundation
import SwiftyJSON

public extension Arb {

    struct Portfolio: BackendModel {

        // MARK: - Public properties

        public let id: Int
        public let name: String
        public let order: Int

        // MARK: - Initialziers

        public init(json: JSON) {
            id = json["id"].intValue
            name = json["name"].stringValue
            order = json["order"].intValue
        }

        public init(id: Int, name: String, order: Int = 0) {
            self.id = id
            self.name = name
            self.order = order
        }
    }
}

extension Arb.Portfolio {

    public var isAra: Bool {
        name.lowercased() == "ara"
    }

    public var isHou: Bool {
        name.lowercased() == "hou"
    }

    public enum PortfolioType: String {
        case comparisonByMonth
        case comparisonByDestination
        case comparisonByRegion
    }
}

extension Arb.Portfolio: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
