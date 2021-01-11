//
//  Date+Sparta.swift
//  
//
//  Created by Yaroslav Babalich on 23.12.2020.
//

import UIKit

public extension Date {

    static func date(from dateString: String, and dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: dateString)
    }

    static func fetchNextMonths(count: Int, withCurrent: Bool = true) -> [Date] {

        let calendar = Calendar.current

        var dates: [Date?] = []
        var monthsCount = count
        var lastDate = Date()

        if withCurrent {
            monthsCount -= 1
            dates.append(lastDate)
        }

        for _ in 0..<monthsCount {
            let generatedDate = calendar.date(byAdding: .month, value: 1, to: lastDate)
            dates.append(generatedDate)
            lastDate = generatedDate!
        }

        return dates.compactMap { $0?.firstMonthDayDate }.sorted(by: <)
    }

    // MARK: - Variables public

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var firstMonthDayDate: Date? {
        let calendar = Calendar.current
        let monthComponents = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: monthComponents)
    }

    // MARK: - Public methods

    func formattedString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
