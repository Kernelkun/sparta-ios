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
            let emptyString = "\u{200B}\u{200B}\u{200B}\u{200B}\u{200B}\u{200B}\u{200B}\u{200B}\u{200B}\u{200B}\u{200B}\u{200B}"
            let title: NSString = """
                \(emptyString) \(emptyString) \(emptyString) \(emptyString) \(emptyString) \(emptyString)   \("ArbsPage.Grade.Arb.Title".localized)
            """ as NSString
            let attributedString = NSMutableAttributedString(string: title as String)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left

            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: title.range(of: title as String))

            return .grade(attributedString: attributedString)
        }

        static var status: Cell {
            let title: NSString = "ArbsPage.Grade.OpenClose.Title".localized as NSString
            let attributedString = NSMutableAttributedString(string: title as String)

            attributedString.addAttributes([.font: UIFont.main(weight: .regular, size: 10)],
                                           range: title.range(of: title as String))

            return .grade(attributedString: attributedString)
        }
        
        static var deliveryMonth: Cell {
            .grade(attributedString: NSAttributedString(string: "ArbsPage.Grade.DlvMonth.Title".localized))
        }

        static var userTgt: Cell {
            let title: String = "ArbsPage.Grade.MyTgt.Title".localized
            let attributedString = NSMutableAttributedString(string: title)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: (title as NSString).range(of: title))
            return .grade(attributedString: attributedString)
        }

        static var userMargin: Cell {
            let title: String = "ArbsPage.Grade.MyMargin.Title".localized
            let attributedString = NSMutableAttributedString(string: title)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: (title as NSString).range(of: title))
            return .grade(attributedString: attributedString)
        }
        static var deliveryPrice: Cell {
            let title: NSString = "ArbsPage.Grade.DlvPrice.Title".localized as NSString
            let attributedString = NSMutableAttributedString(string: title as String)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

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
