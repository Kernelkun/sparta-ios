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
import SpartaHelpers

protocol ArbsViewModelDelegate: class {
    func didReceiveUpdatesForGrades()
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?)
    func didMoveDataSourceSections(fromIndexes: [Int], toIndexes: [Int])
}

class ArbsViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbsViewModelDelegate?

    var tableGrade: Cell = .arb
    var collectionGrades: [Cell] = [.status, .deliveryMonth, .deliveryPrice, .userTgt, .userMargin]

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

    func toggleFavourite(arb: Arb) {
        if let index = fetchedArbs.firstIndex(of: arb) {

            fetchedArbs[index].isFavourite.toggle()

            arbsSyncManager.updateFavouriteState(for: fetchedArbs[index])

            print("ARBDebug: Choosed: \(fetchedArbs[index].grade) - \(fetchedArbs[index].uniqueIdentifier), isFavourite: \(fetchedArbs[index].isFavourite)")

            sortArbs()



            if let indexes = generateDataSourceUpdates() {
                onMainThread {

                    print("ARBDebug: Need to move: \(indexes)")

//                    self.delegate?.didMoveDataSourceSections(fromIndexes: , toIndexes: )
                    self.delegate?.didUpdateDataSourceSections(insertions: IndexSet(indexes.1), removals: IndexSet(indexes.0), updates: [])
                }
            }
        }
    }

    // MARK: - Private methods

    private func createTableDataSource() -> [Cell] {
//        var sortedArbs = arbs.filter { $0.isFavourite }.sorted(by: { $0.priorityIndex < $1.priorityIndex })
//        sortedArbs.append(contentsOf: arbs.filter { !$0.isFavourite }.sorted(by: { $0.priorityIndex < $1.priorityIndex }))
////        sortedArbs.append(contentsOf: arbs.filter { !$0.isFavourite }.sorted(by: { $0.priorityIndex < $1.priorityIndex }))
//
//        print("ARBDebug: Count of arb: \(sortedArbs.count)")
//        print("ARBDebug: sorted: \(sortedArbs.compactMap { $0.priorityIndex.toString + " " + $0.uniqueIdentifier })")

        return fetchedArbs.compactMap { .title(arb: $0) }
    }

    private func createCollectionDataSource() -> [Section] {
//        var sortedArbs = arbs.filter { $0.isFavourite }.sorted(by: { $0.priorityIndex < $1.priorityIndex })
//        sortedArbs.append(contentsOf: arbs.filter { !$0.isFavourite }.sorted(by: { $0.priorityIndex < $1.priorityIndex }))

        return fetchedArbs.compactMap { .init(name: $0.grade,
                                             cells: [.info(arb: $0), .info(arb: $0), .info(arb: $0), .info(arb: $0), .info(arb: $0)]) }
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

// differences & sorting

extension ArbsViewModel {

    private func sortArbs() {

        func sortPredicate(lhs: Arb, rhs: Arb) -> Bool {
            if lhs.isFavourite && rhs.isFavourite {
                return lhs.priorityIndex < rhs.priorityIndex
            } else if lhs.isFavourite && !rhs.isFavourite {
                return true
            } else if !lhs.isFavourite && rhs.isFavourite {
                return false
            } else {
                return lhs.priorityIndex < rhs.priorityIndex
            }
        }

        var sortedArbs = fetchedArbs.sorted { sortPredicate(lhs: $0, rhs: $1) }
//        sortedArbs.append(contentsOf: fetchedArbs.filter { !$0.isFavourite }.sorted(by: { $0.priorityIndex < $1.priorityIndex }))

        fetchedArbs = sortedArbs

                print("ARBDebug: Count of arb: \(fetchedArbs.count)")
                print("ARBDebug: sorted: \(fetchedArbs.compactMap { $0.priorityIndex.toString + " " + $0.uniqueIdentifier })")
    }

    private func updateDataSource() {
        let newTableDataSource = createTableDataSource()
        let newCollectionDataSource = createCollectionDataSource()

        let changes = newTableDataSource.difference(from: tableDataSource)

        let insertedIndexs = changes.insertions.compactMap { change -> Int? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return offset
        }

        let removedIndexs = changes.removals.compactMap { change -> Int? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return offset
        }

        tableDataSource = newTableDataSource
        collectionDataSource = newCollectionDataSource

        onMainThread {
            self.delegate?.didUpdateDataSourceSections(insertions: IndexSet(insertedIndexs),
                                                       removals: IndexSet(removedIndexs),
                                                       updates: [])
        }
    }

    private func generateDataSourceUpdates() -> ([Int], [Int])? {

        let newTableDataSource = createTableDataSource()
        let newCollectionDataSource = createCollectionDataSource()

        print("ARBDebug: OLD: \n")

        tableDataSource.compactMap {
            if case let ArbsViewModel.Cell.title(arb) = $0 {
                print("\nARBDebug: \(arb.uniqueIdentifier)\n")
            }
        }

        let changes = newTableDataSource.difference(from: tableDataSource)

        let insertedIndexs = changes.insertions.compactMap { change -> Int? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return offset
        }

        let removedIndexs = changes.removals.compactMap { change -> Int? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return offset
        }

        print("ArbDebug: Changes \(insertedIndexs), \(removedIndexs) ")

        if !removedIndexs.isEmpty && !insertedIndexs.isEmpty,
           removedIndexs.count == insertedIndexs.count {

            tableDataSource = newTableDataSource
            collectionDataSource = newCollectionDataSource

            return (removedIndexs, insertedIndexs)
        } else {
            return nil
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
        fetchedArbs = arbs
        sortArbs()
        updateDataSource()
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
