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

            attributedString.addAttributes([.font: UIFont.main(weight: .regular, size: 10)], range: title.range(of: title as String))

            return .grade(attributedString: attributedString)
        }
        
        static var deliveryMonth: Cell { .grade(attributedString: NSAttributedString(string: "Dlv\nMonth")) }
        static var userTgt: Cell { .grade(attributedString: NSAttributedString(string: "My\nTGT")) }
        static var userMargin: Cell { .grade(attributedString: NSAttributedString(string: "My\nMargin")) }
        static var deliveryPrice: Cell { .grade(attributedString: NSAttributedString(string: "Dlv\nPrice")) }
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
        } else {
            return false
        }
    }
}
