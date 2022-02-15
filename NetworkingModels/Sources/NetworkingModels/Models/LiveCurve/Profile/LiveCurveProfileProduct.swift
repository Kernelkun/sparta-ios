//
//  LiveCurveProfileProduct.swift
//  
//
//  Created by Yaroslav Babalich on 17.05.2021.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON
import SpartaHelpers

public struct LiveCurveProfileProduct: BackendModel {
    //
    // MARK: - Public properties

    public let id: Int
    public let code: String
    public let shortName: String
    public let longName: String
    public let unit: String
    public let productGroups: [Group]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        code = json["code"].stringValue
        shortName = json["shortName"].stringValue
        longName = json["longName"].stringValue
        unit = json["unit"].stringValue
        productGroups = json["productGroups"].arrayValue.compactMap { Group(json: $0) }
    }
}

extension LiveCurveProfileProduct: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

public extension LiveCurveProfileProduct {

    struct Group: BackendModel {

        //
        // MARK: - Public properties

        public let id: Int
        public let rank: Int

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            id = json["id"].intValue
            rank = json["rank"].intValue
        }
    }
}
