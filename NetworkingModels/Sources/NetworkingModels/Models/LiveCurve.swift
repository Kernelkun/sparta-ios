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
    public let priceValue: Double
    public var state: State = .initial
    public let name: String
    public let longName: String

    public var priceCode: String { name + monthCode }
    public var displayName: String { name }

    public var indexOfMonth: Int? {
        Self.months.firstIndex(of: monthCode)
    }

    public static var months: [String] {
        ["BOM", "M01", "M02", "M03", "M04", "M05"]
    }

    public var priorityIndex: Int {
        _priorityIndex[code] ?? 100
    }

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
    }
}

extension LiveCurve: Equatable {

    public static func ==(lhs: LiveCurve, rhs: LiveCurve) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
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
}

// HOT FIX

extension LiveCurve {

    private var _priorityIndex: [String: Int] {
        ["OTRBSW": 0,
         "ISPEOB": 4,
         "ISPNWE": 11,
         "SPDMJN": 13,
         "PSDREB": 2,
         "SPDMEB": 6,
         "EBOB": 3,
         "NWENAPHTHA": 10,
         "GASNAPHTHA": 9,
         "RBOBSWAP": 1,
         "SING92": 7,
         "SING92SPREADS": 8,
         "EBOBSPREADS": 5,
         "MOPJSPREADS": 14,
         "NWENAPHTHASPREADS": 12]
    }
}
