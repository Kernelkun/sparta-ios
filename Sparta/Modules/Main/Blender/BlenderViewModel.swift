//
//  BlenderViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels

protocol BlenderViewModelDelegate: class {
    func didReceiveUpdatesForGrades()
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?)
}

class BlenderViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    var tableGrade = Cell.grade(title: "Grade")
    var collectionGrades: [Cell] = Array(repeating: .emptyGrade, count: 6)

    var tableDataSource: [Cell] = []
    var collectionDataSource: [Section] = []

    var isSeasonalityOn: Bool = false {
        didSet {
            onMainThread {
                self.updateSeasonalityDataSource()
            }
        }
    }

    weak var delegate: BlenderViewModelDelegate?

    // MARK: - Private properties

    private var blenderManager = App.instance.blenderSyncManager
    private var fetchedBlenders: [Blender] = []

    // MARK: - Public methods

    func loadData() {
        updateConnectionInfo()

        blenderManager.delegate = self
        blenderManager.startReceivingData()

        // sockets

        observeApp(for: .socketsState)
    }

    func fetchDescription(for indexPath: IndexPath) -> BlenderMonthDetailModel? {

        let section = indexPath.section
        let monthIndex = indexPath.row

        guard fetchedBlenders.count > section else { return nil }

        let blender = fetchedBlenders[section]

        guard blender.months.count > monthIndex else { return nil }

        let month = blender.months[monthIndex]

        let mainKeyValues: [BlenderMonthDetailModel.KeyValueParameter] = [
            .init(key: "Argus Ebob Barge Swap", value: month.basisValue + " $/mt", priorityIndex: 0),
            .init(key: "Gas-Naphtha", value: month.naphthaValue + " $/mt", priorityIndex: 1),
            .init(key: "Escalation", value: blender.escalation, priorityIndex: 2)
        ]

        var componentsKeyValues: [BlenderMonthDetailModel.KeyValueParameter] = []

        for (index, element) in month.components.enumerated() {
            componentsKeyValues.append(.init(key: element.name, value: element.value, priorityIndex: index))
        }

        return BlenderMonthDetailModel(mainKeyValues: mainKeyValues, componentsKeyValues: componentsKeyValues)
    }

    func sendAnalyticsEventPopupShown() {
        let trackModel = AnalyticsManager.AnalyticsTrack(name: .popupShown, parameters: [
            "name": "Blender"
        ])

        AnalyticsManager.intance.track(trackModel)
    }

    func height(for section: Int) -> CGFloat {
        guard isSeasonalityOn else { return 50 }

        return 70
    }

    func monthsCount() -> Int {
        6
    }

    func toggleFavourite(blender: Blender) {
        if let index = fetchedBlenders.firstIndex(of: blender) {

            // update blenders favourite states

            fetchedBlenders[index].isFavourite.toggle()
            blenderManager.updateFavouriteState(for: fetchedBlenders[index])
            sortBlenders()

            if let indexes = generateDataSourceUpdates() {
                onMainThread {
                    self.delegate?.didUpdateDataSourceSections(insertions: IndexSet(indexes.1),
                                                               removals: IndexSet(indexes.0),
                                                               updates: [])
                }
            }
        }
    }

    // MARK: - Private methods

    private func updateSeasonalityDataSource() {
        var indexesForUpdates: [Int] = []

        for index in 0..<collectionDataSource.count {
            indexesForUpdates.append(index)
        }

        self.delegate?.didUpdateDataSourceSections(insertions: [],
                                                   removals: [],
                                                   updates: IndexSet(indexesForUpdates))
    }

    private func createTableDataSource() -> [Cell] {
        fetchedBlenders.compactMap { .title(blender: $0) }
    }

    private func createCollectionDataSource() -> [Section] {
        fetchedBlenders.compactMap { blender in

            var cells: [Cell] = Array(repeating: Cell.info(month: .empty), count: monthsCount())

            for (index, month) in blender.months.enumerated() {
                cells[index] = Cell.info(month: month)
            }

            return Section(cells: cells)
        }
    }

    private func updateGrades() {
        collectionGrades = fetchedBlenders.last?.months.compactMap { Cell.grade(title: $0.name) } ?? []

        onMainThread {
            self.delegate?.didReceiveUpdatesForGrades()
        }
    }

    private func updateConnectionInfo() {

        let app = App.instance
        let socketsState = app.socketsState
        let formattedDate = blenderManager.lastSyncDate?.formattedString(AppFormatter.timeDate)

        onMainThread {
            self.delegate?.didChangeConnectionData(title: socketsState.title,
                                                   color: socketsState.color,
                                                   formattedDate: formattedDate)
        }
    }
}

// differences & sorting

extension BlenderViewModel {

    private func sortBlenders() {

        func sortPredicate(lhs: Blender, rhs: Blender) -> Bool {
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

        fetchedBlenders = fetchedBlenders.sorted { sortPredicate(lhs: $0, rhs: $1) }
    }

    private func updateBlenders() {

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

extension BlenderViewModel: AppObserver {

    func appSocketsDidChangeState(for server: SocketAPI.Server, state: SocketAPI.State) {
        updateConnectionInfo()
    }
}

extension BlenderViewModel: BlenderSyncManagerDelegate {

    func blenderSyncManagerDidFetch(blenders: [Blender]) {
        onMainThread {
            self.fetchedBlenders = blenders
            self.sortBlenders()

            self.updateBlenders()
            self.updateGrades()
        }
    }

    func blenderSyncManagerDidReceive(blender: Blender) {
        fetchedBlenders.append(blender)
        sortBlenders()

        updateBlenders()
        updateGrades()
    }

    func blenderSyncManagerDidReceiveUpdates(for blender: Blender) {
        if let indexOfBlender = fetchedBlenders.firstIndex(of: blender) {
            fetchedBlenders[indexOfBlender] = blender
            tableDataSource[indexOfBlender] = Cell.title(blender: blender)
            collectionDataSource[indexOfBlender].cells = blender.months.compactMap { Cell.info(month: $0) }
        }

        updateGrades()
    }

    func blenderSyncManagerDidChangeSyncDate(_ newDate: Date?) {
        updateConnectionInfo()
    }
}
