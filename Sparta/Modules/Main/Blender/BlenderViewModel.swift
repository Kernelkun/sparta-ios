//
//  BlenderViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import Foundation
import Networking
import SwiftyJSON
import NetworkingModels

protocol BlenderViewModelDelegate: class {
    func blenderDidLoadInfo()
}

class BlenderViewModel {

    enum Cell {
        case grade(title: String)
        case info(title: String)
    }

    struct Section {

        // MARK: - Public properties

        let cells: [Cell]
    }

    // MARK: - Public properties

    var tableDataSource: [Cell] = []
    var collectionDataSource: [Section] = []

    weak var delegate: BlenderViewModelDelegate?

    // MARK: - Public methods

    func connectToSockets() {
        observeSocket(for: .blender)
        App.instance.socketsConnect(toServer: .blender)
    }

    func loadData() {

        tableDataSource = [
            .info(title: "E5 BOB"),
            .info(title: "E10 BOB"),
            .info(title: "RBOB"),
            .info(title: "CBOB"),
            .info(title: "Sing 2"),
            .info(title: "E10 BOB"),
            .info(title: "RBOB"),
            .info(title: "CBOB"),
            .info(title: "Sing 2"),
            .info(title: "E10 BOB"),
            .info(title: "RBOB"),
            .info(title: "CBOB"),
            .info(title: "Sing 2"),
            .info(title: "E10 BOB"),
            .info(title: "RBOB"),
            .info(title: "CBOB"),
            .info(title: "Sing 2"),
            .info(title: "E10 BOB"),
            .info(title: "RBOB"),
            .info(title: "CBOB"),
            .info(title: "Sing 2"),
            .info(title: "E10 BOB"),
            .info(title: "RBOB"),
            .info(title: "CBOB"),
            .info(title: "Sing 2")
        ]

        let gradeSection = Section(cells: [
            .grade(title: "Jan 20"),
            .grade(title: "Feb 20"),
            .grade(title: "Mar 20"),
            .grade(title: "Apr 20"),
            .grade(title: "May 20"),
            .grade(title: "Jun 20")
        ])

        let collectionSections: [Section] = tableDataSource.compactMap { _ -> Section in

            var cells: [Cell] = []

            for _ in 0..<gradeSection.cells.count {
                cells.append(.info(title: "\(Int.random(in: -5...5))"))
            }

            return Section(cells: cells)
        }

        collectionDataSource = collectionSections

        // add grades

        tableDataSource.insert(.grade(title: "Grade"), at: 0)
        collectionDataSource.insert(gradeSection, at: 0)

        delegate?.blenderDidLoadInfo()
    }
}

extension BlenderViewModel: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {
        print("-socketDidReceiveResponse: \(server), blender grade: \(Blender(json: data).grade)")
    }
}
