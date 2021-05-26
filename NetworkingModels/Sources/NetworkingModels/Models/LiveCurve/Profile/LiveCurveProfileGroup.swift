//
//  LiveCurveProfileGroup.swift
//  
//
//  Created by Yaroslav Babalich on 17.05.2021.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON
import SpartaHelpers

public struct LiveCurveProfileGroup: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let name: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
    }
}

extension LiveCurveProfileGroup: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
