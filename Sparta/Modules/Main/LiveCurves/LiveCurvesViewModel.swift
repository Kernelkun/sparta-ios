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

protocol LiveCurvesViewModelDelegate: class {
    func didReceiveUpdatesForGrades()
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
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

        // test

//        tableDataSource = [.grade(title: "BOM"), .grade(title: "TELL"), .grade(title: "STOP"), .grade(title: "SYSTEM")]
//        collectionDataSource = [
//            Section(cells: [.info(model: .init(numberPoint: .init(text: "+1", textColor: .red)))])
//        ]

        delegate?.didReceiveUpdatesForGrades()
    }

    // MARK: - Private methods

    private func createTableDataSource(from liveCurves: [LiveCurve]) -> [Cell] {
        var result: [Cell] = []
        result = liveCurves.compactMap { liveCurve in
            return .grade(title: liveCurve.name.uppercased())
        }
        return result
    }

    private func createCollectionDataSource(from liveCurves: [LiveCurve]) -> [Section] {
        liveCurves.compactMap { liveCurve -> Section in

            let name = liveCurve.name
            let cells = priceCodes(for: liveCurve.name).compactMap { priceCode -> Cell in
                .info(monthInfo: LiveCurveMonthInfoModel(priceValue: liveCurve.priceCode == priceCode ? "\(liveCurve.priceValue)" : nil,
                                                         priceCode: priceCode))
            }

            let tempSection = Section(name: name, cells: cells)

            if let indexOfSection = collectionDataSource.firstIndex(of: tempSection) {

                guard let indexOfMonth = liveCurve.indexOfMonth else {
                    return collectionDataSource[indexOfSection]
                }

                var updatedSection = collectionDataSource[indexOfSection]

                updatedSection.cells[indexOfMonth] = .info(monthInfo: LiveCurveMonthInfoModel(priceValue: "\(liveCurve.priceValue)",
                                                                                              priceCode: liveCurve.priceCode))
                return updatedSection
            } else {
                return tempSection
            }
        }
    }

    private func priceCodes(for name: String) -> [String] {
        LiveCurve.months.compactMap { name + $0 }
    }
}

extension LiveCurvesViewModel: LiveCurvesSyncManagerDelegate {

    func liveCurvesSyncManagerDidFetch(liveCurves: [LiveCurve]) {
        updateLiveCurves(liveCurves)
    }

    func liveCurvesSyncManagerDidReceive(liveCurve: LiveCurve) {
        var liveCurves: [LiveCurve] = fetchedLiveCurves
        liveCurves.append(liveCurve)

        updateLiveCurves(liveCurves)

        print(liveCurve)
    }

    func liveCurvesSyncManagerDidReceiveUpdates(for liveCurve: LiveCurve) {
        if let indexOfLiveCurve = fetchedLiveCurves.firstIndex(of: liveCurve) {
            fetchedLiveCurves[indexOfLiveCurve] = liveCurve

            if let indexOfMonth = liveCurve.indexOfMonth {
                collectionDataSource[indexOfLiveCurve].cells[indexOfMonth] = .info(monthInfo: .init(priceValue: "\(liveCurve.priceValue)",
                                                                                                    priceCode: liveCurve.priceCode))
            }
        }
    }
}

// differences

extension LiveCurvesViewModel {

    private func updateLiveCurves(_ newLiveCurves: [LiveCurve]) {
        let changes = newLiveCurves.difference(from: fetchedLiveCurves)

        let insertedIndexPaths = changes.insertions.compactMap { change -> IndexPath? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return IndexPath(row: 0, section: offset)
        }

        let removedIndexPaths = changes.removals.compactMap { change -> IndexPath? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return IndexPath(row: 0, section: offset)
        }

        fetchedLiveCurves = newLiveCurves

        tableDataSource = createTableDataSource(from: newLiveCurves)
        collectionDataSource = createCollectionDataSource(from: newLiveCurves)

        let insertionsIndexSet = IndexSet(insertedIndexPaths.compactMap { $0.section })
        let removalsIndexSet = IndexSet(removedIndexPaths.compactMap { $0.section })

        onMainThread {
            self.delegate?.didUpdateDataSourceSections(insertions: insertionsIndexSet,
                                                       removals: removalsIndexSet,
                                                       updates: [])
        }
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
