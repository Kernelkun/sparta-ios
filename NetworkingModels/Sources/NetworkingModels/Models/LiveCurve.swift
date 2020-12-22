//
//  LiveCurve.swift
//  
//
//  Created by Yaroslav Babalich on 14.12.2020.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON

public struct LiveCurve: BackendModel {

    //
    // MARK: - Public properties

    public let date: String
    public let monthCode: String
    public let monthDisplay: String
    public let priceCode: String
    public let priceValue: Double
    public let inputs: [String: Any]
    public var state: State = .initial

    public var name: String {
        guard let range = priceCode.range(of: monthCode) else { return priceCode }

        var newPriceCode = priceCode
        newPriceCode.removeSubrange(range)
        return newPriceCode
    }

    public var displayName: String {
        displayName(for: name) ?? name
    }

    public var indexOfMonth: Int? {
        Self.months.firstIndex(of: monthCode)
    }

    public static var months: [String] {
        ["BOM", "M01", "M02", "M03", "M04", "M05"]
    }

    public var priorityIndex: Int {
        _priorityIndex[name] ?? 100
    }

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        let responseArray = json.stringValue.components(separatedBy: ",")

        print("-TEST: \(responseArray)")

        inputs = [:]

        if responseArray.count > 0 {
            date = responseArray[0] as String
        } else {
            date = ""
        }

        if responseArray.count > 1 {
            monthCode = responseArray[1] as String
        } else {
            monthCode = ""
        }

        if responseArray.count >= 2 {
            monthDisplay = responseArray[2] as String
        } else {
            monthDisplay = ""
        }

        if responseArray.count >= 3 {
            priceCode = responseArray[3] as String
        } else {
            priceCode = ""
        }

        if responseArray.count >= 4 {
            priceValue = Double(responseArray[4]) ?? 0.0
        } else {
            priceValue = 0.0
        }
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
            case .up: return .green
            case .down: return .red
            }
        }
    }
}

// HOT FIX

extension LiveCurve {

    private var _displayNames: [String: String] {
        ["OTRBSW": "Brent Swap",
         "ISPEOB": "EBOB Crk",
         "ISPNWE": "Nap NWE Crk",
         "SPDMJN": "E/W Nap",
         "PSDREB": "TA Arb",
         "SPDMEB": "E/W Gas",
         "EBOB": "EBOB",
         "NWENAPHTHA": "Nap NWE",
         "GASNAPHTHA": "Gas-Nap",
         "RBOBSWAP": "RBOB Swap",
         "SING92": "Sing92",
         "EBOBSPREADS": "EBOB Spd",
         "MOPJSPREADS": "MOPJ Spd",
         "SING92SPREADS": "Sing92 Spd",
         "NWENAPHTHASPREADS": "Nap NWE Spd"]
    }

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

    private func displayName(for code: String) -> String? {
        _displayNames[code]
    }
}
