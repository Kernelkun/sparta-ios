//
//  LiveCurvesViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 20.05.2021.
//

import Foundation
import NetworkingModels

extension LiveCurvesViewModel {

    enum Cell {
        case grade(title: String)
        case gradeUnit(title: String, unit: String)
        case info(monthInfo: LiveCurveMonthInfoModel)

        static func emptyGrade() -> Cell { .grade(title: "") }
    }

    struct Section {
        let name: String
        let code: String
        var cells: [Cell]
    }

    enum PresentationStyle {
        case months
        case quartersAndYears

        // MARK: - Public properties

        var rowsCount: Int {
            switch self {
            case .months:
                return LiveCurve.months.count

            case .quartersAndYears:
                return LiveCurve.quartersAndYears.count
            }
        }

        var rowsData: [String] {
            switch self {
            case .months:
                return LiveCurve.months

            case .quartersAndYears:
                return LiveCurve.quartersAndYears
            }
        }

        // MARK: - Public methods

        mutating func toggle() {
            switch self {
            case .months:
                self = .quartersAndYears
                
            case .quartersAndYears:
                self = .months
            }
        }
    }
}

extension LiveCurvesViewModel.Section: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }
}
