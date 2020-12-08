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
    func didUpdateDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet, afterSeasonality: Bool)
}

class BlenderViewModel {

    enum Cell {
        case grade(title: String)
        case info(model: BlenderMonthInfoModel)
    }

    struct Section {

        // MARK: - Public properties

        let cells: [Cell]
    }

    // MARK: - Public properties

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

        blenderManager.delegate = self
        blenderManager.loadData()
    }

    func fetchDescription(for indexPath: IndexPath) -> BlenderMonthDetailModel? {

        let section = indexPath.section
        let monthIndex = indexPath.row

        guard fetchedBlenders.count > section, section != 0 else { return nil }

        let blender = fetchedBlenders[section]

        guard blender.months.count > monthIndex else { return nil }

        let month = blender.months[monthIndex]

        let mainKeyValues: [String: String] = [
            "Argus Ebob Barge Swap": month.basisValue + " $/mt",
            "Gas-Naphtha": month.naphthaValue + " $/mt",
            "Escalation": blender.escalation
        ]

        var componentsKeyValues: [String: String] = [:]

        month.components.forEach {
            componentsKeyValues[$0.name] = $0.value
        }

        return BlenderMonthDetailModel(mainKeyValues: mainKeyValues, componentsKeyValues: componentsKeyValues)
    }

    func height(for section: Int) -> CGFloat {
        guard section > 0 else { return 30 }

        guard isSeasonalityOn else { return 60 }

        let months = fetchedBlenders[section].months

        if months.contains(where: { $0.seasonality.trimmed.nullable != nil }) {
            return 80
        } else {
            return 60
        }
    }

    // MARK: - Private methods

    private func updateSeasonalityDataSource() {
        tableDataSource = createTableDataSource(from: fetchedBlenders)

        collectionDataSource = createCollectionDataSource(from: fetchedBlenders, with: fetchCollectionGrades())

        var indexesForUpdates: [Int] = []

        for index in 0..<collectionDataSource.count {
            indexesForUpdates.append(index)
        }

        self.delegate?.didUpdateDataSourceSections(insertions: [],
                                                   removals: [],
                                                   updates: IndexSet(indexesForUpdates),
                                                   afterSeasonality: true)
    }

    private func createTableDataSource(from blenders: [Blender]) -> [Cell] {
        var blenders = blenders
        blenders.remove(at: 0)

        var result: [Cell] = []
        result = blenders.compactMap { blender in

            let numberPoint = BlenderMonthInfoModel.PointModel(text: blender.grade, textColor: .white)
            var seasonalityPoint: BlenderMonthInfoModel.PointModel?

            if isSeasonalityOn, blender.months.contains(where: { $0.seasonality.trimmed.nullable != nil }) {
                seasonalityPoint = BlenderMonthInfoModel.PointModel(text: "Seasonality", textColor: .gray)
            }

            return .info(model: BlenderMonthInfoModel(numberPoint: numberPoint, seasonalityPoint: seasonalityPoint))
        }
        result.insert(.grade(title: "Grade"), at: 0)
        return result
    }

    private func createCollectionDataSource(from blenders: [Blender], with monthsGrades: [String]) -> [Section] {
        var blenders = blenders
        blenders.remove(at: 0)

        let gradeSection = Section(cells: monthsGrades.compactMap { .grade(title: $0) })

        var collectionSections: [Section] = blenders.compactMap { blender -> Section in

            var cells: [Cell] = []

            for month in blender.months {
                let color: UIColor = month.color == "RED" ? .red : .green

                let numberPoint = BlenderMonthInfoModel.PointModel(text: month.value, textColor: color)
                var seasonalityPoint: BlenderMonthInfoModel.PointModel?

                if isSeasonalityOn, let seasonality = month.seasonality.trimmed.nullable {
                    seasonalityPoint = BlenderMonthInfoModel.PointModel(text: seasonality, textColor: .gray)
                }

                cells.append(.info(model: BlenderMonthInfoModel(numberPoint: numberPoint, seasonalityPoint: seasonalityPoint)))
            }

            return Section(cells: cells)
        }

        collectionSections.insert(gradeSection, at: 0)

        return collectionSections
    }

    private func fetchCollectionGrades() -> [String] {
        fetchedBlenders.last?.months.compactMap { $0.name } ?? []
    }
}

// differences

extension BlenderViewModel {

    private func updateBlenders(_ newBlenders: [Blender]) {
        let changes = newBlenders.difference(from: fetchedBlenders)

        let insertedIndexPaths = changes.insertions.compactMap { change -> IndexPath? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return IndexPath(row: 0, section: offset)
        }

        let removedIndexPaths = changes.removals.compactMap { change -> IndexPath? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return IndexPath(row: 0, section: offset)
        }

        fetchedBlenders = newBlenders

        tableDataSource = createTableDataSource(from: newBlenders)
        collectionDataSource = createCollectionDataSource(from: newBlenders, with: fetchCollectionGrades())

        let insertionsIndexSet = IndexSet(insertedIndexPaths.compactMap { $0.section })
        let removalsIndexSet = IndexSet(removedIndexPaths.compactMap { $0.section })

        onMainThread {
            self.delegate?.didUpdateDataSourceSections(insertions: insertionsIndexSet,
                                                       removals: removalsIndexSet,
                                                       updates: [],
                                                       afterSeasonality: false)
        }
    }
}

extension BlenderViewModel: BlenderSyncManagerDelegate {

    func blenderSyncManagerDidFetch(blenders: [Blender]) {

        var blenders = blenders
        blenders.insert(Blender.empty, at: 0)

        updateBlenders(blenders)
    }

    func blenderSyncManagerDidReceive(blender: Blender) {
        var newBlenders = Array(fetchedBlenders)

        newBlenders.insert(Blender.empty, at: 0)
        newBlenders.append(blender)

        updateBlenders(newBlenders)
    }

    func blenderSyncManagerDidReceiveUpdates(for blender: Blender) {
        if let indexOfBlender = fetchedBlenders.firstIndex(of: blender) {
            fetchedBlenders[indexOfBlender] = blender

            collectionDataSource[indexOfBlender] = Section(cells: blender.months.compactMap({ month -> Cell in
                let color: UIColor = month.color == "RED" ? .red : .green

                let numberPoint = BlenderMonthInfoModel.PointModel(text: month.value, textColor: color)
                var seasonalityPoint: BlenderMonthInfoModel.PointModel?

                if isSeasonalityOn, let seasonality = month.seasonality.trimmed.nullable {
                    seasonalityPoint = BlenderMonthInfoModel.PointModel(text: seasonality, textColor: .gray)
                }

                return .info(model: BlenderMonthInfoModel(numberPoint: numberPoint, seasonalityPoint: seasonalityPoint))
            }))

            print("blenderSyncManagerDidReceiveUpdates \(blender.grade)")

            onMainThread(delay: 1) {
                self.delegate?.didUpdateDataSourceSections(insertions: [],
                                                           removals: [],
                                                           updates: IndexSet([indexOfBlender]),
                                                           afterSeasonality: false)
            }
        }
    }
}
