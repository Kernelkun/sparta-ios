//
//  BlenderViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.02.2021.
//

import Foundation
import NetworkingModels
import UIKit

extension BlenderViewModel {

    struct BlenderCell {
        let blender: Blender
        var isParrent: Bool { blender.isParrent }
    }

    struct BlenderMonthCell {
        let month: BlenderMonth
        let isParrent: Bool
    }

    enum Cell {
        case grade(title: String)
        case title(blenderCell: BlenderCell)
        case info(blenderMonthCell: BlenderMonthCell)

        static let emptyGrade: Cell = .grade(title: "")
    }

    struct Section {
        let gradeCode: String
        var cells: [Cell]
    }
}

extension BlenderViewModel.Cell: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        if case let BlenderViewModel.Cell.grade(leftGrade) = lhs,
           case let BlenderViewModel.Cell.grade(rightGrade) = rhs {

            return leftGrade.lowercased() == rightGrade.lowercased()
        } else if case let BlenderViewModel.Cell.title(leftBlender) = lhs,
                  case let BlenderViewModel.Cell.title(rightBlender) = rhs {

            return leftBlender.blender == rightBlender.blender
        } else if case let BlenderViewModel.Cell.info(leftBlenderMonth) = lhs,
                  case let BlenderViewModel.Cell.info(rightBlenderMonth) = rhs {

            return leftBlenderMonth.month == rightBlenderMonth.month
        }

        return false
    }
}

extension BlenderViewModel.Section: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.gradeCode.lowercased() == rhs.gradeCode.lowercased()
    }
}
