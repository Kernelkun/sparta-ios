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
import SpartaHelpers

protocol BlenderViewModelDelegate: AnyObject {
    func didReceiveUpdatesForGrades()
    func didReceiveUpdatesForPresentationStyle()
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
    func didReceiveProfilesInfo(profiles: [BlenderProfileCategory], selectedProfile: BlenderProfileCategory?)
    func didChangeConnectionData(title: String, color: UIColor, formattedDate: String?)
}

class BlenderViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    var tableGrade = Cell.grade(title: "Grade.Title".localized)
    lazy var collectionGrades: [Cell] = Array(repeating: .emptyGrade, count: monthsCount())

    var selectedSection: Int?

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
        blenderManager.start()

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

        var mainKeyValues: [BlenderMonthDetailModel.KeyValueParameter] = []

        let priceInfo = blender.priceInfo.sorted(by: { $0.order < $1.order })

        for (index, priceInfo) in priceInfo.enumerated() {
            if let priceValue = month.priceValue.first(where: { $0.id == priceInfo.id }) {
                mainKeyValues.append(.init(key: priceInfo.name,
                                           value: priceValue.value + " \(priceInfo.unit)", priorityIndex: index))
            }
        }

        // % Pxg of Nap
        if let pxgNapValue = month.naphthaPricingComponentsVolume.toDouble?.roundedString(to: 1) {
            mainKeyValues.append(.init(key: "% Pxg of Nap", value: pxgNapValue + "%", priorityIndex: mainKeyValues.count))
        }

        // density of blend
        if let densityValue = month.density.toDouble?.roundedString(to: 4) {
            mainKeyValues.append(.init(key: "Density", value: densityValue + " t/m³", priorityIndex: mainKeyValues.count + 1))
        }

        // escalation
        if blenderManager.profile.portfolio == .ara {
            mainKeyValues.append(.init(key: "Escalation", value: blender.escalation, priorityIndex: mainKeyValues.count + 2))
        }

        if blender.isCustom, let blenderConfigurationName = blender.portfolioConfiguration.name?.nullable {
            mainKeyValues.append(.init(key: "Configuration", value: blenderConfigurationName, priorityIndex: mainKeyValues.count + 3))
        }

        var componentsKeyValues: [BlenderMonthDetailModel.KeyValueParameter] = []

        for (index, element) in month.components.enumerated() {
            componentsKeyValues.append(.init(key: element.name, value: element.value, priorityIndex: index))
        }

        return BlenderMonthDetailModel(mainKeyValues: mainKeyValues, componentsKeyValues: componentsKeyValues)
    }

    func changeProfile(_ profile: BlenderProfileCategory) {
        blenderManager.setProfile(profile)
    }

    func sendAnalyticsEventPopupShown() {
        let trackModel = AnalyticsManager.AnalyticsTrack(name: .popupShown, parameters: [
            "name": "Blender"
        ])

        AnalyticsManager.intance.track(trackModel)
    }

    func height(for section: Int) -> CGFloat {
        guard !isSeasonalityOn else { return 70 }

        return selectedSection == section ? 130 : 50
    }

    func monthsCount() -> Int {
        blenderManager.profile.portfolio == .ara ? 6 : blenderManager.houMonthsCount
    }

    func activateSection(_ activeSection: Int) {
        selectedSection = activeSection

        self.delegate?.didUpdateDataSourceSections(insertions: [],
                                                   removals: [],
                                                   updates: IndexSet([activeSection]))
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

    private func createTableDataSource(for blenders: [Blender]) -> [Cell] {
        var cells: [Cell] = []
        for (index, blender) in blenders.enumerated() {
            cells.append(.title(blenderCell: BlenderCell(blender: blender)))
        }
        return cells
    }

    private func createCollectionDataSource(for blenders: [Blender]) -> [Section] {
        var sections: [Section] = []

        for (blenderIndex, blender) in blenders.enumerated() {
            var cells: [Cell] = Array(repeating: Cell.emptyGrade, count: blender.months.count)

            for (index, month) in blender.months.enumerated() {

                cells[index] = Cell.info(blenderMonthCell: BlenderMonthCell(
                    month: month,
                    isParrent: blender.isParrent))
            }

            sections.append(Section(gradeCode: blender.gradeCode, cells: cells))
        }

        return sections
    }

    private func updateGrades() {
        collectionGrades = fetchedBlenders.last?.months.compactMap { Cell.grade(title: $0.name) }
            ?? Array(repeating: .emptyGrade, count: monthsCount())

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

    private func sortedBlenders(_ blenders: [Blender]) -> [Blender] {
        func sortPredicate(lhs: Blender, rhs: Blender) -> Bool {
            lhs.priorityIndex < rhs.priorityIndex
        }

        return blenders.sorted { sortPredicate(lhs: $0, rhs: $1) }
    }

    private func updateBlenders(for blenders: [Blender]) {
        let newTableDataSource = createTableDataSource(for: blenders)
        let newCollectionDataSource = createCollectionDataSource(for: blenders)

        let changes = newCollectionDataSource.difference(from: collectionDataSource)

        let insertedIndexs = changes.insertions.compactMap { change -> Int? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return offset
        }

        let removedIndexs = changes.removals.compactMap { change -> Int? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return offset
        }

        fetchedBlenders = blenders

        tableDataSource = newTableDataSource
        collectionDataSource = newCollectionDataSource

        onMainThread {
            self.delegate?.didUpdateDataSourceSections(insertions: IndexSet(insertedIndexs),
                                                       removals: IndexSet(removedIndexs),
                                                       updates: [])
        }
    }
}

extension BlenderViewModel: AppObserver {

    func appSocketsDidChangeState(for server: SocketAPI.Server, state: SocketAPI.State) {
        updateConnectionInfo()
    }
}

extension BlenderViewModel: BlenderSyncManagerDelegate {

    func blenderSyncManagerDidFetch(blenders: [Blender], profiles: [BlenderProfileCategory], selectedProfile: BlenderProfileCategory?) {
        delegate?.didReceiveProfilesInfo(profiles: profiles, selectedProfile: selectedProfile)

        updateBlenders(for: sortedBlenders(blenders))

        delegate?.didReceiveUpdatesForPresentationStyle()
        updateGrades()
    }

    func blenderSyncManagerDidReceive(blender: Blender) {
        var updatedBlenders = fetchedBlenders
        updatedBlenders.append(blender)

        updateBlenders(for: sortedBlenders(updatedBlenders))
        updateGrades()
    }

    func blenderSyncManagerDidReceiveUpdates(for blender: Blender) {
        if let indexOfBlender = fetchedBlenders.firstIndex(of: blender) {
            fetchedBlenders[indexOfBlender] = blender
            tableDataSource[indexOfBlender] = Cell.title(blenderCell: .init(blender: blender))
            collectionDataSource[indexOfBlender].cells = blender.months.compactMap { Cell.info(blenderMonthCell: BlenderMonthCell(month: $0,
                                                                                                                                  isParrent: blender.isParrent)) }
        }

        updateGrades()
    }

    func blenderSyncManagerDidChangeSyncDate(_ newDate: Date?) {
        updateConnectionInfo()
    }
}
