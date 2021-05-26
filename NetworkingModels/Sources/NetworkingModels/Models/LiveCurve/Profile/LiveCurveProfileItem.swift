//
//  LiveCurveProfileItem.swift
//  
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON
import SpartaHelpers

public struct LiveCurveProfileItem: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let code: String
    public let shortName: String
    public let longName: String
    public let order: Int

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        code = json["code"].stringValue
        shortName = json["shortName"].stringValue
        longName = json["longName"].stringValue
        order = json["order"].intValue
    }
}

extension LiveCurveProfileItem: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.code.lowercased() == rhs.code.lowercased()
    }
}
