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

protocol LiveCurvesViewModelDelegate: AnyObject {
    func didReceiveUpdatesForGrades()
    func didReceiveUpdatesForPresentationStyle()
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
    func didReceiveProfilesInfo(profiles: [LiveCurveProfileCategory], selectedProfile: LiveCurveProfileCategory?)
    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?)
}

class LiveCurvesViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LiveCurvesViewModelDelegate?

    var presentationStyle: PresentationStyle = .months

    var tableGrade: Cell = .emptyGrade()
    lazy var collectionGrades: [Cell] = presentationStyle.rowsData.compactMap { Cell.grade(title: $0) }

    var tableDataSource: [Cell] = []
    var collectionDataSource: [Section] = []

    var isAbleToAddNewPortfolio: Bool {
        let liveCurvesCount = liveCurvesSyncManager.profile?.liveCurves.count ?? 0
        return liveCurvesCount < AppFormatter.Restrictions.maxPortfolioItemsNumbers
    }

    let cellAnimationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "uiAnimation"
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 100
        return queue
    }()

    // MARK: - Private properties

    private var liveCurvesSyncManager = App.instance.liveCurvesSyncManager
    private var fetchedLiveCurves: [LiveCurve] = []

    // MARK: - Public methods

    func loadData() {
        updateConnectionInfo()

        liveCurvesSyncManager.delegate = self
        liveCurvesSyncManager.start()
        observeApp(for: .socketsState)

        updateGrades()
    }

    func stopLoadData() {
        App.instance.socketsConnect()
        stopObservingApp(for: .socketsState)
    }

    func changeProfile(_ profile: LiveCurveProfileCategory) {
        liveCurvesSyncManager.setProfile(profile)
    }

    func togglePresentationStyle() {
        self.presentationStyle.toggle()

        reloadDataSource(liveCurvesSyncManager.profileLiveCurves)
        updateGrades()

        delegate?.didReceiveUpdatesForPresentationStyle()
    }

    // MARK: - Private methods

    private func createTableDataSource(from liveCurves: [LiveCurve]) -> [Cell] {
        Dictionary(grouping: liveCurves, by: { $0.code })
            .sorted(by: { value1, value2 in
                value1.value.first?.priorityIndex ?? 0 < value2.value.first?.priorityIndex ?? 1
            })
            .compactMap { .gradeUnit(title: $0.value.first.required().displayName, unit: $0.value.first.required().unit) }
    }

    private func createCollectionDataSource(from liveCurves: [LiveCurve]) -> [Section] {
        Dictionary(grouping: liveCurves, by: { $0.code })
            .sorted(by: { value1, value2 -> Bool in
                value1.value.first?.priorityIndex ?? 0 < value2.value.first?.priorityIndex ?? 1
            })
            .compactMap { key, value -> Section in

                var cells: [Cell] = Array(repeating: .emptyGrade(), count: presentationStyle.rowsCount)

                value.forEach { liveCurve in
                    guard let indexOfMonth = liveCurve.indexOfMonth else { return }

                    cells[indexOfMonth] = Cell.info(monthInfo: .init(priceValue: liveCurve.displayPrice,
                                                                     priceCode: liveCurve.priceCode,
                                                                     monthDisplayName: liveCurve.monthDisplay,
                                                                     lcCode: liveCurve.code,
                                                                     lcName: liveCurve.name,
                                                                     lcUnit: liveCurve.unit))
                }

                let firstObject = value.first.required()
                let tempSection = Section(name: firstObject.displayName, code: firstObject.code, cells: cells)
                return tempSection
            }
    }

    private func updateGrades() {
        collectionGrades = presentationStyle.rowsData.compactMap { rowData -> Cell in
            if let liveCurve = fetchedLiveCurves.first(where: { $0.monthCode == rowData }) {
                return .grade(title: liveCurve.monthDisplay)
            }

            return Cell.grade(title: rowData)
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

    func liveCurvesSyncManagerDidFetch(
        liveCurves: [LiveCurve],
        profiles: [LiveCurveProfileCategory],
        selectedProfile: LiveCurveProfileCategory?
    ) {
        delegate?.didReceiveProfilesInfo(profiles: profiles, selectedProfile: selectedProfile)

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
               let indexInDataSource = collectionDataSource.firstIndex(where: { $0.code == liveCurve.code }) {

                let priceCode = liveCurve.priceCode
                let monthInfo: LiveCurveMonthInfoModel = .init(
                    priceValue: liveCurve.displayPrice,
                    priceCode: priceCode,
                    monthDisplayName: liveCurve.monthDisplay,
                    lcCode: liveCurve.code,
                    lcName: liveCurve.name,
                    lcUnit: liveCurve.unit)
                collectionDataSource[indexInDataSource].cells[indexOfMonth] = .info(monthInfo: monthInfo)
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
        let newLiveCurves = filtered(newLiveCurves)

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

        fetchedLiveCurves = newLiveCurves.sorted(by: { $0.priorityIndex < $01.priorityIndex })

        tableDataSource = newTableDataSource
        collectionDataSource = newCollectionDataSource

        onMainThread {
            self.delegate?.didUpdateDataSourceSections(insertions: IndexSet(insertedIndexs),
                                                       removals: IndexSet(removedIndexs),
                                                       updates: [])
        }
    }

    private func reloadDataSource(_ newLiveCurves: [LiveCurve]) {

        let newLiveCurves = filtered(newLiveCurves)

        let newTableDataSource = createTableDataSource(from: newLiveCurves)
        let newCollectionDataSource = createCollectionDataSource(from: newLiveCurves)

        fetchedLiveCurves = newLiveCurves.sorted(by: { $0.priorityIndex < $01.priorityIndex })

        tableDataSource = newTableDataSource
        collectionDataSource = newCollectionDataSource

        var reloadIndexs: [Int] = []

        for i in 0..<collectionDataSource.count {
            reloadIndexs.append(i)
        }

        onMainThread {
            self.delegate?.didUpdateDataSourceSections(insertions: [],
                                                       removals: [],
                                                       updates: IndexSet(reloadIndexs))
        }
    }

    private func filtered(_ newLiveCurves: [LiveCurve]) -> [LiveCurve] {
        switch presentationStyle {
        case .months:
            return newLiveCurves.filter { $0.presentationType == .months }

        case .quartersAndYears:
            return newLiveCurves.filter { $0.presentationType == .quartersAndYears }
        }
    }
}

extension LiveCurvesViewModel: AppObserver {

    func appSocketsDidChangeState(for server: SocketAPI.Server, state: SocketAPI.State) {
        updateConnectionInfo()
    }
}
