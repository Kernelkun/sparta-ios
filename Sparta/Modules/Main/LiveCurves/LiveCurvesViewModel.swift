//
//  LiveCurvesViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol LiveCurvesViewModelDelegate: class {
    func didReceiveUpdatesForGrades()
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?)
}

class LiveCurvesViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LiveCurvesViewModelDelegate?

    var tableGrade: Cell = .emptyGrade()
    var collectionGrades: [Cell] = Array(repeating: .emptyGrade(), count: 6)

    var tableDataSource: [Cell] = []
    var collectionDataSource: [Section] = []

    // MARK: - Private properties

    private let liveCurvesSyncManager = App.instance.liveCurvesSyncManager
    private var fetchedLiveCurves: [LiveCurve] = []

    // MARK: - Public methods

    func loadData() {
        liveCurvesSyncManager.delegate = self
        liveCurvesSyncManager.startReceivingData()

        collectionGrades = LiveCurve.months.compactMap { Cell.grade(title: $0) }

        delegate?.didReceiveUpdatesForGrades()

        observeApp(for: .socketsState)
    }

    func stopLoadData() {
        App.instance.socketsConnect()
        stopObservingApp(for: .socketsState)
    }

    func monthsCount() -> Int {
        LiveCurve.months.count
    }

    // MARK: - Private methods

    private func createTableDataSource(from liveCurves: [LiveCurve]) -> [Cell] {
//        let sortedLiveCurves = liveCurves.sorted(by: { $0.priorityIndex > $1.priorityIndex })

        return Dictionary(grouping: liveCurves, by: { $0.displayName }).keys.compactMap { key -> Cell in
            .grade(title: key)
        }
    }

    private func createCollectionDataSource(from liveCurves: [LiveCurve]) -> [Section] {
//        let sortedLiveCurves = liveCurves.sorted(by: { $0.priorityIndex > $1.priorityIndex })

        return Dictionary(grouping: liveCurves, by: { $0.displayName }).compactMap { key, value -> Section in

            var cells: [Cell] = Array(repeating: .emptyGrade(), count: LiveCurve.months.count)

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
            }
        }
    }

    private func priceCodes(for name: String) -> [String] {
        LiveCurve.months.compactMap { name + $0 }
    }

    private func updateGrades() {
        collectionGrades = collectionGrades.compactMap { cell -> Cell in
            if case let Cell.grade(title) = cell {
                if let liveCurve = fetchedLiveCurves.first(where: { $0.monthCode == title }) {
                    return .grade(title: liveCurve.monthDisplay)
                }
            }

            return cell
        }

        onMainThread {
            self.delegate?.didReceiveUpdatesForGrades()
        }
    }

    private func updateConnectionInfo() {

        let app = App.instance
        let socketsState = app.socketsState
        let formattedDate = liveCurvesSyncManager.lastSyncDate?.formattedString(AppFormatter.timeDate)

        onMainThread {
            self.delegate?.didChangeConnectionData(title: socketsState.title,
                                                   color: socketsState.color,
                                                   formattedDate: formattedDate)
        }
    }
}

extension LiveCurvesViewModel: LiveCurvesSyncManagerDelegate {

    func liveCurvesSyncManagerDidFetch(liveCurves: [LiveCurve]) {
        updateDataSource(liveCurves)

        updateGrades()
    }

    func liveCurvesSyncManagerDidReceive(liveCurve: LiveCurve) {
        var liveCurves: [LiveCurve] = fetchedLiveCurves
        liveCurves.append(liveCurve)

        updateDataSource(liveCurves)

        updateGrades()
    }

    func liveCurvesSyncManagerDidReceiveUpdates(for liveCurve: LiveCurve) {
        if let indexOfLiveCurve = fetchedLiveCurves.firstIndex(of: liveCurve) {
            fetchedLiveCurves[indexOfLiveCurve] = liveCurve

            if let indexOfMonth = liveCurve.indexOfMonth,
               let indexInDataSource = collectionDataSource.firstIndex(where: { $0.name == liveCurve.name }) {

                let priceCode = liveCurve.priceCode

                collectionDataSource[indexInDataSource].cells[indexOfMonth] = .info(monthInfo: .init(priceValue: liveCurve.priceValue,
                                                                                                    priceCode: priceCode))
            }
        }

        updateGrades()
    }

    func liveCurvesSyncManagerDidChangeSyncDate(_ newDate: Date?) {
        updateConnectionInfo()
    }
}

// differences

extension LiveCurvesViewModel {

    private func updateDataSource(_ newLiveCurves: [LiveCurve]) {

        let newTableDataSource = createTableDataSource(from: newLiveCurves)
        let newCollectionDataSource = createCollectionDataSource(from: newLiveCurves)

        let changes = newCollectionDataSource.difference(from: collectionDataSource)

        let insertedIndexs = changes.insertions.compactMap { change -> Int? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return offset
        }

        let removedIndexs = changes.removals.compactMap { change -> Int? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return offset
        }

        fetchedLiveCurves = newLiveCurves

        tableDataSource = newTableDataSource
        collectionDataSource = newCollectionDataSource

        onMainThread {
            self.delegate?.didUpdateDataSourceSections(insertions: IndexSet(insertedIndexs),
                                                       removals: IndexSet(removedIndexs),
                                                       updates: [])
        }
    }
}

extension LiveCurvesViewModel: AppObserver {

    func appSocketsDidChangeState(for server: SocketAPI.Server, state: SocketAPI.State) {
        updateConnectionInfo()
    }
}

extension LiveCurvesViewModel {

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

extension LiveCurvesViewModel.Section: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }
}
