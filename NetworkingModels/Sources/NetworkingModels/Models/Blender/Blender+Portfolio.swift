//
//  Blender+Portfolio.swift
//  
//
//  Created by Yaroslav Babalich on 12.10.2021.
//

import SwiftyJSON

public extension Blender {

    struct Portfolio: BackendModel {

        // MARK: - Public properties

        public let id: Int
        public let name: String

        // MARK: - Initialziers

        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        public init(json: JSON) {
            id = json["portfolioId"].intValue
            name = json["portfolioName"].stringValue
        }
    }
}

extension Blender.Portfolio: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
