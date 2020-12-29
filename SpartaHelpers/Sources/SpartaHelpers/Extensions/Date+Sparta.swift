//
//  Date+Sparta.swift
//  
//
//  Created by Yaroslav Babalich on 23.12.2020.
//

import UIKit

public extension Date {

    static public func date(from dateString: String, and dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: dateString)
    }

    // MARK: - Variables public

    public var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    public var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    // MARK: - Public methods

    public func formattedString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
