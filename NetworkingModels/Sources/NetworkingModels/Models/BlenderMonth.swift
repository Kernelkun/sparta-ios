//
//  BlenderMonth.swift
//  
//
//  Created by Yaroslav Babalich on 03.12.2020.
//

import UIKit
import Foundation
import SwiftyJSON

public struct BlenderMonth: BackendModel {

    //
    // MARK: - Public properties

    public let disabled: Bool
    public let name: String
    public let gradeCode: String
    public let value: String
    public let color: String
    public let seasonality: String
    public let basisValue: String
    public let naphthaValue: String
    public let components: [BlenderMonthComponent]

    public var observableName: String { name + gradeCode }

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        disabled = json["disabled"].boolValue
        name = json["name"].stringValue

        let month = json["month"].dictionaryValue

        value = month["value"]?.stringValue ?? ""
        color = month["color"]?.stringValue ?? ""
        seasonality = month["seasonality"]?.stringValue ?? ""
        basisValue = month["basisValue"]?.stringValue ?? ""
        naphthaValue = month["naphthaValue"]?.stringValue ?? ""
        gradeCode = month["gradeCode"]?.stringValue ?? ""

        components = month["components"]?.arrayValue.compactMap { BlenderMonthComponent(json: $0) } ?? []
    }
}

extension BlenderMonth {

    public var textColor: UIColor {
        switch color.lowercased() {
        case "red":
            return .numberRed
        case "green":
            return .numberGreen
        default:
            return .numberGray
        }
    }
}
