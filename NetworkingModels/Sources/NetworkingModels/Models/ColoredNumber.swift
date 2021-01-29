//
//  ColoredNumber.swift
//  
//
//  Created by Yaroslav Babalich on 30.12.2020.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON
import SpartaHelpers

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

public extension ColoredNumber {

    var valueColor: UIColor {
        switch color.lowercased() {
        case "red":
            return .numberRed
        case "green":
            return .numberGreen
        case "gray":
            return .numberGray
        default:
            return .numberGray
        }
    }
}
