//
//  Date+WeekDay.swift
//  
//
//  Created by Yaroslav Babalich on 09.05.2022.
//

import Foundation

public extension Date {

    enum WeekDay: Int {
        case sunday = 1
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }

    func getWeekDay() -> WeekDay {
        let calendar = Calendar.current
        let weekDay = calendar.component(Calendar.Component.weekday, from: self)
        return WeekDay(rawValue: weekDay)!
    }
}
