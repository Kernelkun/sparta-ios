//
//  BlenderViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.02.2021.
//

import Foundation
import NetworkingModels

extension BlenderViewModel {

    enum Cell {
        case grade(title: String)
        case title(blender: Blender)
        case info(month: BlenderMonth)

        static let emptyGrade: Cell = .grade(title: "")
    }

    struct Section {
        var cells: [Cell]
    }
}
extension BlenderViewModel.Cell: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        if case let BlenderViewModel.Cell.grade(leftGrade) = lhs,
           case let BlenderViewModel.Cell.grade(rightGrade) = rhs {

            return leftGrade.lowercased() == rightGrade.lowercased()
        } else if case let BlenderViewModel.Cell.title(leftArb) = lhs,
                  case let BlenderViewModel.Cell.title(rightArb) = rhs {

            return leftArb == rightArb
        } else if case let BlenderViewModel.Cell.info(leftArb) = lhs,
                  case let BlenderViewModel.Cell.info(rightArb) = rhs {

            return leftArb == rightArb
        }

        return false
    }
}
