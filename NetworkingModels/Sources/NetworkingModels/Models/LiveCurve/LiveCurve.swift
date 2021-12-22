//
//  LiveCurve.swift
//  
//
//  Created by Yaroslav Babalich on 14.12.2020.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON
import SpartaHelpers

public struct LiveCurve: BackendModel {

    //
    // MARK: - Public properties

    public let date: String
    public let monthCode: String
    public let monthDisplay: String
    public let code: String
    public var priceValue: Double
    public let isEmpty: Bool
    public var unit: String
    public var state: State = .initial
    public let presentationType: PresentationType
    public let name: String
    public let longName: String

    public var priceCode: String { name + monthCode }

    public var displayName: String { name }
    public var displayPrice: String {
        if isEmpty {
            return "-"
        } else {
            return priceValue.symbols2Value
        }
    }

    public var indexOfMonth: Int? {
        if Self.months.contains(monthCode) {
            return Self.months.firstIndex(of: monthCode)
        } else {
            return Self.quartersAndYears.firstIndex(of: monthCode)
        }
    }

    public static var months: [String] {
        ["BOM", "M01", "M02", "M03", "M04", "M05",
         "M06", "M07", "M08", "M09", "M10", "M11",
         "M12", "M13", "M14", "M15", "M16"]
    }

    public static var quartersAndYears: [String] {
        ["BOQ", "Q01", "Q02", "Q03", "Q04",
         "BOY", "CL1", "CL2"]
    }

    public var priorityIndex: Int

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        date = json["datetime"].stringValue
        monthCode = json["monthCode"].stringValue
        monthDisplay = json["monthName"].stringValue
        name = json["shortName"].stringValue
        longName = json["longName"].stringValue
        code = json["code"].stringValue
        priceValue = json["price"].doubleValue
        isEmpty = json["isEmpty"].boolValue
        unit = json["unit"].stringValue
        priorityIndex = -1
        presentationType = Self.months.contains(monthCode) ? .months : .quartersAndYears
    }
}

extension LiveCurve: Equatable {

    public static func ==(lhs: LiveCurve, rhs: LiveCurve) -> Bool {
        lhs.priceCode.lowercased() == rhs.priceCode.lowercased()
    }
}

extension LiveCurve {

    public enum State {
        case initial
        case up
        case down

        public var color: UIColor {
            switch self {
            case .initial: return .clear
            case .up: return .numberGreen
            case .down: return .numberRed
            }
        }
    }

    public enum PresentationType {
        case months
        case quartersAndYears
    }
}
