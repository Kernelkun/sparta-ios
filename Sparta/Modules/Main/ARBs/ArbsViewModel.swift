//
//  ArbsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels

protocol ArbsViewModelDelegate: class {
    func didReceiveUpdatesForGrades()
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?)
}

class ArbsViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbsViewModelDelegate?

    var tableGrade: Cell = .grade(title: "ARB")
    var collectionGrades: [Cell] = [.grade(title: "Load/Delivery\nMonth"), .grade(title: "Blend\nCost"),
                                    .grade(title: "Freight"), .grade(title: "Delivery\nPrice")]

    var tableDataSource: [Cell] = [.grade(title: "One")]
    var collectionDataSource: [Section] = [.init(name: "New", cells: [.emptyGrade(), .emptyGrade(), .emptyGrade()])]

    // MARK: - Private properties

    // MARK: - Public methods

    func loadData() {
        delegate?.didReceiveUpdatesForGrades()
    }

    func rowsCount() -> Int {
        collectionGrades.count
    }
}

extension ArbsViewModel {

    enum Cell {
        case grade(title: String)
        case info(monthInfo: LiveCurveMonthInfoModel)

        static func emptyGrade() -> Cell { .grade(title: "") }
    }

    struct Section {
        let name: String
        var cells: [Cell]
    }
}

extension ArbsViewModel.Section: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }
}
