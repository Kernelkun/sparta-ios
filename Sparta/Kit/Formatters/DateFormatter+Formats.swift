//
//  DateFormatter+Formats.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.05.2022.
//

import Foundation

extension DateFormatter {
    static var mmmYY: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }
}
