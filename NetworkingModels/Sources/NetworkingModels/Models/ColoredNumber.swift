//
//  ColoredNumber.swift
//  
//
//  Created by Yaroslav Babalich on 30.12.2020.
//

import Foundation
import SwiftyJSON

public struct ColoredNumber: BackendModel {

    //
    // MARK: - Public properties

    public let value: String
    public let color: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        value = json["value"].stringValue
        color = json["color"].stringValue
    }
}
