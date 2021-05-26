//
//  ArbsViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 22.01.2021.
//

import UIKit
import NetworkingModels

extension ArbsViewModel {

    enum Cell {
        case grade(attributedString: NSAttributedString)
        case title(arb: Arb)
        case info(arb: Arb)

        static var arb: Cell {
            let title: NSString = "ARB"
            let attributedString = NSMutableAttributedString(string: title as String)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: title.range(of: title as String))

            return .grade(attributedString: attributedString)
        }

        static var status: Cell {
            let title: NSString = "Open\\Close"
            let attributedString = NSMutableAttributedString(string: title as String)

            attributedString.addAttributes([.font: UIFont.main(weight: .regular, size: 10)],
                                           range: title.range(of: title as String))

            return .grade(attributedString: attributedString)
        }
        
        static var deliveryMonth: Cell { .grade(attributedString: NSAttributedString(string: "Dlv\nMonth")) }
        static var userTgt: Cell {
            let title: String = "My\nTGT"
            let attributedString = NSMutableAttributedString(string: title)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right

            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: (title as NSString).range(of: title))
            return .grade(attributedString: attributedString)
        }
        static var userMargin: Cell {
            let emptyString = "\u{200B}"
            let title: String =
                """
                My \(emptyString) \n\(emptyString)Margin \(emptyString)
                """
            let attributedString = NSMutableAttributedString(string: title)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right

            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: (title as NSString).range(of: title))
            return .grade(attributedString: attributedString)
        }
        static var deliveryPrice: Cell {
            let title: NSString = "Dlv\nPrice"
            let attributedString = NSMutableAttributedString(string: title as String)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right

            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: title.range(of: title as String))

            return .grade(attributedString: attributedString)
        }
    }

    struct Section {
        let name: String
        var cells: [Cell]
    }
}

extension ArbsViewModel.Cell: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        if case let ArbsViewModel.Cell.grade(leftGrade) = lhs,
           case let ArbsViewModel.Cell.grade(rightGrade) = rhs {

            return leftGrade.string.lowercased() == rightGrade.string.lowercased()
        } else if case let ArbsViewModel.Cell.title(leftArb) = lhs,
                  case let ArbsViewModel.Cell.title(rightArb) = rhs {

            return leftArb.uniqueIdentifier == rightArb.uniqueIdentifier
        } else if case let ArbsViewModel.Cell.info(leftArb) = lhs,
                  case let ArbsViewModel.Cell.info(rightArb) = rhs {

            return leftArb.uniqueIdentifier == rightArb.uniqueIdentifier
        }

        return false
    }
}

extension ArbsViewModel.Section: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }
}
