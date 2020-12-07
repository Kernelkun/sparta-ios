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
    func didUpdateCollectionDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
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

    var isSeasonalityOn: Bool = false

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

        let section = indexPath.section - 1
        let monthIndex = indexPath.row

        guard fetchedBlenders.count > section else { return nil }

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

    func collectionSize(for indexPath: IndexPath) -> CGSize {
        guard indexPath.section > 0 else {
            return CGSize(width: 80, height: 30)
        }

        guard isSeasonalityOn else {
            return CGSize(width: 80, height: 60)
        }

        let months = fetchedBlenders[indexPath.section - 1].months
        if months.first(where: { $0.seasonality.trimmed.nullable != nil }) != nil {
            return CGSize(width: 80, height: 80)
        } else {
            return CGSize(width: 80, height: 60)
        }
    }

    func tableSize(for indexPath: IndexPath) -> CGSize {
        guard indexPath.section > 0 else {
            return CGSize(width: 80, height: 30)
        }

        guard isSeasonalityOn else {
            return CGSize(width: 80, height: 60)
        }

        let months = fetchedBlenders[indexPath.section - 1].months
        if months.first(where: { $0.seasonality.trimmed.nullable != nil }) != nil {
            return CGSize(width: 80, height: 80)
        } else {
            return CGSize(width: 80, height: 60)
        }
    }

    // MARK: - Private methods

    private func createTableDataSource(from blenders: [Blender]) -> [Cell] {
        var blenders = blenders
        blenders.remove(at: 0)

        var result: [Cell] = []
        result = blenders.compactMap { Cell.info(model: BlenderMonthInfoModel(numberPoint: .init(text: $0.grade, textColor: .white))) }
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

                if let seasonality = month.seasonality.trimmed.nullable {
                    seasonalityPoint = BlenderMonthInfoModel.PointModel(text: seasonality, textColor: .gray)
                }

                cells.append(.info(model: BlenderMonthInfoModel(numberPoint: numberPoint, seasonalityPoint: seasonalityPoint)))
            }

            return Section(cells: cells)
        }

        collectionSections.insert(gradeSection, at: 0)

        return collectionSections
    }
}

// differences

extension BlenderViewModel {

    private func updateBlenders(_ newBlenders: [Blender], with monthsGrades: [String]) {
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
        collectionDataSource = createCollectionDataSource(from: newBlenders, with: monthsGrades)

        let insertionsIndexSet = IndexSet(insertedIndexPaths.compactMap { $0.section })
        let removalsIndexSet = IndexSet(removedIndexPaths.compactMap { $0.section })

        onMainThread {
            self.delegate?.didUpdateCollectionDataSourceSections(insertions: insertionsIndexSet,
                                                                 removals: removalsIndexSet,
                                                                 updates: [])
        }
    }
}

extension BlenderViewModel: BlenderSyncManagerDelegate {

    func blenderSyncManagerDidFetch(blenders: [Blender], monthsGrades: [String]) {

        var blenders = blenders
        blenders.insert(Blender.empty, at: 0)

        updateBlenders(blenders, with: monthsGrades)
    }

    func blenderSyncManagerDidReceive(blender: Blender) {
        var newBlenders = Array(fetchedBlenders)

        newBlenders.insert(Blender.empty, at: 0)
        newBlenders.append(blender)

        updateBlenders(newBlenders, with: [])
    }

    func blenderSyncManagerDidReceiveUpdates(for blender: Blender) {
        if let indexOfBlender = fetchedBlenders.firstIndex(of: blender) {
            fetchedBlenders[indexOfBlender] = blender

            collectionDataSource[indexOfBlender] = Section(cells: blender.months.compactMap({ month -> Cell in
                let color: UIColor = month.color == "RED" ? .red : .green

                let numberPoint = BlenderMonthInfoModel.PointModel(text: month.value, textColor: color)
                var seasonalityPoint: BlenderMonthInfoModel.PointModel?

                if let seasonality = month.seasonality.trimmed.nullable {
                    seasonalityPoint = BlenderMonthInfoModel.PointModel(text: seasonality, textColor: .gray)
                }

                return .info(model: BlenderMonthInfoModel(numberPoint: numberPoint, seasonalityPoint: seasonalityPoint))
            }))

            print("blenderSyncManagerDidReceiveUpdates \(blender.grade)")

            onMainThread(delay: 1) {
                self.delegate?.didUpdateCollectionDataSourceSections(insertions: [], removals: [], updates: IndexSet([indexOfBlender]))
            }
        }
    }
}
