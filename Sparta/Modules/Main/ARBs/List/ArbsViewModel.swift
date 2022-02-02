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

protocol ArbsViewModelDelegate: AnyObject {
    func didReceiveUpdatesForGrades()
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
    func didReceiveProfilesInfo(profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?)
    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?)
}

class ArbsViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbsViewModelDelegate?

    var tableGrade: Cell = .arb
    var collectionGrades: [Cell] {
        guard let portfolio = arbsSyncManager.portfolio else {
            return [.status, .deliveryMonth, .deliveryPrice, .vsHou, .userTgt, .userMargin]
        }

        if portfolio.portfolio.isAra {
            return [.status, .deliveryMonth, .deliveryPrice, .vsHou, .userTgt, .userMargin]
        } else {
            return [.status, .deliveryMonth, .deliveryPrice, .vsAra, .userTgt, .userMargin]
        }
    }

    var tableDataSource: [Cell] = []
    var collectionDataSource: [Section] = []

    // MARK: - Private properties

    private let arbsSyncManager = App.instance.arbsSyncManager
    private var fetchedArbs: [Arb] = []

    // MARK: - Initializers

    override init() {
        super.init()

        observeArbsSyncManagerStates()
    }

    deinit {
        stopObservingAllArbsSyncManagerStates()
    }

    // MARK: - Public methods

    func loadData() {
        updateConnectionInfo()

        arbsSyncManager.start()

        delegate?.didReceiveUpdatesForGrades()
    }

    func rowsCount() -> Int {
        collectionGrades.count
    }

    func fetchUpdatedArb(for arb: Arb) -> Arb? {
        guard let arbIndex = fetchedArbs.firstIndex(of: arb) else { return nil }

        return fetchedArbs[arbIndex]
    }

    func changeProfile(_ portfolio: ArbProfileCategory) {
        arbsSyncManager.setPortfolio(portfolio)
        delegate?.didReceiveUpdatesForGrades()
    }

    // MARK: - Private methods

    private func createTableDataSource() -> [Cell] {
        return fetchedArbs.compactMap { .title(arb: $0) }
    }

    private func createCollectionDataSource() -> [Section] {
        return fetchedArbs.compactMap {
            let cells: [Cell] = [.info(arb: $0), .info(arb: $0), .info(arb: $0), .info(arb: $0), .info(arb: $0), .info(arb: $0)]
            return .init(name: $0.grade, cells: cells)
        }
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
            lhs.priorityIndex < rhs.priorityIndex
        }

        fetchedArbs = fetchedArbs.sorted { sortPredicate(lhs: $0, rhs: $1) }
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

        let changes = newTableDataSource.difference(from: tableDataSource)

        let insertedIndexs = changes.insertions.compactMap { change -> Int? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return offset
        }

        let removedIndexs = changes.removals.compactMap { change -> Int? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return offset
        }

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

extension ArbsViewModel: ArbsSyncManagerObserver {

    func arbsSyncManagerDidChangeLoadingState(_ isLoading: Bool) {
    }

    func arbsSyncManagerDidFetch(arbs: [Arb], profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?) {
        delegate?.didReceiveProfilesInfo(profiles: profiles, selectedProfile: selectedProfile)

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
