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
    func didUpdateTableDataSource(insertions: [IndexPath], removals: [IndexPath], updates: [IndexPath])
    func didUpdateCollectionDataSourceSections(insertions: IndexSet, removals: IndexSet, updates: IndexSet)
    func blenderDidLoadInfo()
}

class BlenderViewModel {

    enum Cell {
        case grade(title: String)
        case info(title: String, textColor: UIColor)
    }

    struct Section {

        // MARK: - Public properties

        let cells: [Cell]
    }

    // MARK: - Public properties

    var tableDataSource: [Cell] = []
    var collectionDataSource: [Section] = []

    weak var delegate: BlenderViewModelDelegate?

    // MARK: - Private properties

    private var blenderManager = App.instance.blenderSyncManager
    private var fetchedBlenders: [Blender] = []

    // MARK: - Public methods

    func connectToSockets() {
        
    }

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
}

// differences

extension BlenderViewModel {

    private func updateBlenders(_ newBlenders: [Blender]) {
        let changes = newBlenders.difference(from: fetchedBlenders)

        let insertedIndexPaths = changes.insertions.compactMap { change -> IndexPath? in
            guard case let .insert(offset, _, _) = change else { return nil }

            return IndexPath(row: offset + 1, section: 0)
        }

        let removedIndexPaths = changes.removals.compactMap { change -> IndexPath? in
            guard case let .remove(offset, _, _) = change else { return nil }

            return IndexPath(row: offset + 1, section: 0)
        }

        fetchedBlenders = newBlenders

        tableDataSource = fetchedBlenders.compactMap { Cell.info(title: $0.grade, textColor: .white) }
        tableDataSource.insert(.grade(title: "Grade"), at: 0)

        /*let collectionSections: [Section] = fetchedBlenders.compactMap { blender -> Section in

            var cells: [Cell] = []

            for month in blender.months {
                let color: UIColor = month.color == "RED" ? .red : .green
                cells.append(.info(title: month.value, textColor: color))
            }

            return Section(cells: cells)
        }

        collectionDataSource = collectionSections
        
        let gradeSection = Section(cells: [
            .grade(title: "Jan 20"),
            .grade(title: "Feb 20"),
            .grade(title: "Mar 20"),
            .grade(title: "Apr 20"),
            .grade(title: "May 20"),
            .grade(title: "Jun 20")
        ])

        collectionDataSource.insert(gradeSection, at: 0)*/

//        let collectionViewInsertions = IndexSet(insertedIndexPaths.compactMap { $0.row })

        onMainThread {
            self.delegate?.didUpdateTableDataSource(insertions: insertedIndexPaths, removals: removedIndexPaths, updates: [])
//            self.delegate?.didUpdateCollectionDataSourceSections(insertions: collectionViewInsertions, removals: [], updates: [])
        }
    }
}

extension BlenderViewModel: BlenderSyncManagerDelegate {

    func blenderSyncManagerDidFetch(blenders: [Blender], monthsGrades: [String]) {

        fetchedBlenders = blenders

        // table view

        tableDataSource = fetchedBlenders.compactMap { Cell.info(title: $0.grade, textColor: .white) }
        tableDataSource.insert(.grade(title: "Grade"), at: 0)

        // collection view

        let gradeSection = Section(cells: monthsGrades.compactMap { .grade(title: $0) })

        var collectionSections: [Section] = fetchedBlenders.compactMap { blender -> Section in

            var cells: [Cell] = []

            for month in blender.months {
                let color: UIColor = month.color == "RED" ? .red : .green
                cells.append(.info(title: month.value, textColor: color))
            }

            return Section(cells: cells)
        }

        collectionSections.insert(gradeSection, at: 0)

        collectionDataSource = collectionSections

        delegate?.blenderDidLoadInfo()
    }

    func blenderSyncManagerDidReceive(blender: Blender) {
        var newBlenders = Array(fetchedBlenders)
        newBlenders.append(blender)
        updateBlenders(newBlenders)
    }

    func blenderSyncManagerDidReceiveUpdates(for blender: Blender) {
        if let indexOfBlender = fetchedBlenders.firstIndex(of: blender) {
            fetchedBlenders[indexOfBlender] = blender

            collectionDataSource[indexOfBlender + 1] = Section(cells: blender.months.compactMap({ month -> Cell in
                let color: UIColor = month.color == "RED" ? .red : .green
                return .info(title: month.value, textColor: color)
            }))

            print("blenderSyncManagerDidReceiveUpdates \(blender.grade)")

            onMainThread(delay: 3) {
                self.delegate?.didUpdateCollectionDataSourceSections(insertions: [], removals: [], updates: IndexSet([indexOfBlender]))
            }
        }
    }
}
