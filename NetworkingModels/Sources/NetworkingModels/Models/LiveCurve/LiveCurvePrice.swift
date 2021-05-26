//
//  LiveCurvePrice.swift
//  
//
//  Created by Yaroslav Babalich on 12.05.2021.
//

import Foundation
import SwiftyJSON

public struct LiveCurvePrice: BackendModel {

    //
    // MARK: - Public properties

    public let code: String
    public let periodCode: String
    public let priceValue: Double

    public var uniqueIdentifier: String {
        code + periodCode
    }

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        code = json["code"].stringValue
        periodCode = json["periodCode"].stringValue
        priceValue = json["price"].doubleValue
    }
}

extension LiveCurvePrice: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
}
