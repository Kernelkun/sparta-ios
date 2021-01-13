//
//  General+Sparta.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

public extension Int {

    var toString: String { String(self) }

    var toFormattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.allowsFloats = false
        formatter.zeroSymbol = nil
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
}

public extension String {

    var toInt: Int? { Int(self) }

    var toDouble: Double? {
        guard let numberString = self.numberString else { return nil }

        return Double(numberString)
    }

    var numberString: String? {
        guard let regex = try? NSRegularExpression(pattern: "[^0-9.]", options: .caseInsensitive) else { return nil }

        return regex.stringByReplacingMatches(in: self,
                                              options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: "")
    }

    var toNumberFormattedString: String? {
        Double(self)?.toFormattedString
    }
}
