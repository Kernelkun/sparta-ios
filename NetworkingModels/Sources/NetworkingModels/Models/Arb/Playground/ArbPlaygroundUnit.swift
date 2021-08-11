//
//  ArbPlaygroundUnit.swift
//  
//
//  Created by Yaroslav Babalich on 26.07.2021.
//

import Foundation
import SwiftyJSON

public struct ArbPlaygroundUnit: BackendModel {

    //
    // MARK: - Public properties

    public var value: Double?
    public let units: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        value = json["value"].double
        units = json["units"].stringValue
    }
}
