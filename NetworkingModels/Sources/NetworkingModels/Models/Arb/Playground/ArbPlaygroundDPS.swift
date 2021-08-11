//
//  ArbPlaygroundDPS.swift
//  
//
//  Created by Yaroslav Babalich on 26.07.2021.
//

import Foundation
import SwiftyJSON

public struct ArbPlaygroundDPS: BackendModel {

    //
    // MARK: - Public properties

    public let monthCode: String
    public let monthName: String
    public let name: String
    public let value: Double

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        monthCode = json["monthCode"].stringValue
        monthName = json["monthName"].stringValue
        name = json["name"].stringValue
        value = json["value"].doubleValue
    }
}

extension ArbPlaygroundDPS: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}
