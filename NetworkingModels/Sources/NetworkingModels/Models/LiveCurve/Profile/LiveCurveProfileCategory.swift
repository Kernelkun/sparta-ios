//
//  LiveCurveProfileCategory.swift
//  
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON
import SpartaHelpers

public struct LiveCurveProfileCategory: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let name: String
    public let liveCurves: [LiveCurveProfileItem]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        liveCurves = json["liveCurves"].arrayValue.compactMap { LiveCurveProfileItem(json: $0) }
    }

    // MARK: - Public methods

    public func contains(liveCurve: LiveCurve) -> Bool {
        liveCurves.compactMap { $0.code }.contains(liveCurve.code)
    }
}

extension LiveCurveProfileCategory: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
