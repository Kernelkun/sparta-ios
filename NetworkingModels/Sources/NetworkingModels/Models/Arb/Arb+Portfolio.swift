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

        // MARK: - Initialziers

        public init(json: JSON) {
            id = json["portfolioId"].intValue
            name = json["portfolioName"].stringValue
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

}

extension Arb.Portfolio: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
