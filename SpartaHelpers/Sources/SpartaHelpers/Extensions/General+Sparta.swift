//
//  General+Sparta.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import UIKit.UIColor
import Foundation

public extension Int {

    var toString: String { String(self) }

    var toFormattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = false
        formatter.zeroSymbol = nil
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: NSNumber(integerLiteral: self)) ?? String(self)
    }
}

public extension Double {

    var toString: String { String(self) }

    var symbols2Value: String { String(format: "%.2f", self) }

    var toFormattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = true
        formatter.zeroSymbol = nil
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    var toDisplayFormattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = true
//        formatter.zeroSymbol = nil
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en")
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    var toFormattedPercentageString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    var toFormattedTime: String {
        let minute = Int(self) / 60 % 60
        let second = Int(self) % 60

        // return formated string
        return String(format: "%02i:%02i", minute, second)
    }

    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func roundedString(to places: Int) -> String {
        String(format: "%.\(places)f", self)
    }

    // appropriate color

    var color: UIColor {
        switch self {
        case let digit where digit > 0:
            return .numberGreen

        case let digit where digit < 0:
            return .numberRed

        default:
            return .numberGray
        }
    }
}

public extension String {

    var toInt: Int? { Int(self) }

    var toDouble: Double? {
        guard let numberString = self.numberString else { return nil }

        return Double(numberString)
    }

    var numberString: String? {
        guard let regex = try? NSRegularExpression(pattern: "[^-+0-9.]", options: .caseInsensitive) else { return nil }

        return regex.stringByReplacingMatches(in: self,
                                              options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: "")
    }

    var toNumberFormattedString: String? {
        Double(self)?.toFormattedString
    }

    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
