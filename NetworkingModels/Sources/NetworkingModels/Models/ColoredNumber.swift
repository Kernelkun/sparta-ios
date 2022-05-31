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

    public var isVisible: Bool {
        let color = color.trimmed.nullable
        let value = value.trimmed.nullable

        return value != nil && color != nil
    }

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        value = json["value"].stringValue
        color = json["color"].stringValue
    }

    public init(value: String, color: String) {
        self.value = value
        self.color = color
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
