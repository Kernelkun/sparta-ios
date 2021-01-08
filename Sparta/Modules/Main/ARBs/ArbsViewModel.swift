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
    var collectionGrades: [Cell] = [.deliveryMonth, .blendCost, .freight, .deliveryPrice]

    var tableDataSource: [Cell] = []
    var collectionDataSource: [Section] = []

    // MARK: - Private properties

    private let arbsSyncManager = App.instance.arbsSyncManager
    private var fetchedArbs: [Arb] = []

    // MARK: - Public methods

    func loadData() {
        updateConnectionInfo()
        
        arbsSyncManager.delegate = self
        arbsSyncManager.startReceivingData()

        delegate?.didReceiveUpdatesForGrades()
    }

    func rowsCount() -> Int {
        collectionGrades.count
    }

    // MARK: - Private methods

    private func createTableDataSource(from arbs: [Arb]) -> [Cell] {

        arbs.compactMap { .grade(title: $0.grade + "\n" + $0.dischargePortName) }

//        Dictionary(grouping: arbs, by: {  }).keys.compactMap { key -> Cell in
//
//        }
    }

    private func createCollectionDataSource(from arbs: [Arb]) -> [Section] {
//        let sortedLiveCurves = liveCurves.sorted(by: { $0.priorityIndex > $1.priorityIndex })

        arbs.compactMap { .init(name: $0.grade, cells: [.info(arb: $0), .info(arb: $0), .info(arb: $0), .info(arb: $0)]) }

//        return Dictionary(grouping: arbs, by: { $0.grade }).compactMap { key, value -> Section in
//
//            return

            /*var cells: [Cell] = Array(repeating: .emptyGrade(), count: LiveCurve.months.count)

            value.forEach { liveCurve in
                guard let indexOfMonth = liveCurve.indexOfMonth else { return }

                cells[indexOfMonth] = Cell.info(monthInfo: .init(priceValue: liveCurve.priceValue,
                                                                 priceCode: liveCurve.priceCode))
            }

            let tempSection = Section(name: key, cells: cells)

            if let indexOfSection = collectionDataSource.firstIndex(of: tempSection) {

                var updatedSection = collectionDataSource[indexOfSection]

                for liveCurve in value {
                    if let indexOfMonth = liveCurve.indexOfMonth {
                        updatedSection.cells[indexOfMonth] = tempSection.cells[indexOfMonth]
                    }
                }

                return updatedSection
            } else {
                return tempSection
            }*/
//        }
    }

    private func updateConnectionInfo() {

        let app = App.instance
        let socketsState = app.socketsState
        let formattedDate = arbsSyncManager.lastSyncDate?.formattedString(AppFormatter.timeDate)

        onMainThread {
            self.delegate?.didChangeConnectionData(title: socketsState.title,
                                                   color: socketsState.color,
                                                   formattedDate: formattedDate)
        }
    }
}

// differences

extension ArbsViewModel {

    private func updateDataSource(_ newArbs: [Arb]) {

        let newTableDataSource = createTableDataSource(from: newArbs)
        let newCollectionDataSource = createCollectionDataSource(from: newArbs)

        let changes = newCollectionDataSource.difference(from: collectionDataSource)

        let insertedIndexs = changes.insertions.compactMap { change -> Int? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return offset
        }

        let removedIndexs = changes.removals.compactMap { change -> Int? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return offset
        }

        fetchedArbs = newArbs

        tableDataSource = newTableDataSource
        collectionDataSource = newCollectionDataSource

        onMainThread {
            self.delegate?.didUpdateDataSourceSections(insertions: IndexSet(insertedIndexs),
                                                       removals: IndexSet(removedIndexs),
                                                       updates: [])
        }
    }
}

extension ArbsViewModel: AppObserver {

    func appSocketsDidChangeState(for server: SocketAPI.Server, state: SocketAPI.State) {
        updateConnectionInfo()
    }
}

extension ArbsViewModel: ArbsSyncManagerDelegate {

    func arbsSyncManagerDidFetch(arbs: [Arb]) {
        updateDataSource(arbs)
    }

    func arbsSyncManagerDidReceive(arb: Arb) {
        // empty data
    }

    func arbsSyncManagerDidReceiveUpdates(for arb: Arb) {
        if let arbIndex = fetchedArbs.firstIndex(of: arb) {
            fetchedArbs[arbIndex] = arb
        }
    }

    func arbsSyncManagerDidChangeSyncDate(_ newDate: Date?) {
        updateConnectionInfo()
    }
}

extension ArbsViewModel {

    enum Cell {
        case grade(title: String)
        case info(arb: Arb)

        static func emptyGrade() -> Cell { .grade(title: "") }

        static var deliveryMonth: Cell { .grade(title: "Load/Delivery\nMonth") }
        static var blendCost: Cell { .grade(title: "Blend\nCost") }
        static var freight: Cell { .grade(title: "Freight") }
        static var deliveryPrice: Cell { .grade(title: "Delivery\nPrice") }
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

extension ArbsViewModel.Cell: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        if case let ArbsViewModel.Cell.grade(leftGrade) = lhs,
           case let ArbsViewModel.Cell.grade(rightGrade) = rhs {

            return leftGrade.lowercased() == rightGrade.lowercased()
        } else {
            return false
        }
    }
}
