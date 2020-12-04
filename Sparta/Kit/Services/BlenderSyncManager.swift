//
//  BlenderSyncManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.12.2020.
//

import Foundation
import SwiftyJSON
import Networking
import NetworkingModels

protocol BlenderSyncManagerDelegate: class {
    func blenderSyncManagerDidFetch(blenders: [Blender], monthsGrades: [String])
    func blenderSyncManagerDidReceive(blender: Blender)
    func blenderSyncManagerDidReceiveUpdates(for blender: Blender)
}

class BlenderSyncManager {

    // MARK: - Singleton

    static let intance = BlenderSyncManager()

    // MARK: - Public properties

    weak var delegate: BlenderSyncManagerDelegate?

    // MARK: - Private properties

    private var _blenders: [Blender] = []

    // MARK: - Initializers

    init() {
        observeSocket(for: .blender)
    }

    // MARK: - Public methods

    func startSilentLoading() {

    }

    func loadData() {

        if !_blenders.isEmpty {
            let blenders = Array(_blenders)

            let monthsGrades = blenders.first?.months.compactMap { $0.name } ?? []

            delegate?.blenderSyncManagerDidFetch(blenders: blenders, monthsGrades: monthsGrades)
        }
    }

    // MARK: - Private methods
}

extension BlenderSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        let blender = Blender(json: data)

        if !_blenders.contains(blender) {
            _blenders.append(blender)

            onMainThread {
                self.delegate?.blenderSyncManagerDidReceive(blender: blender)
            }
        } else if let blenderIndex = _blenders.firstIndex(of: blender) {
            _blenders[blenderIndex] = blender

            onMainThread {
                self.delegate?.blenderSyncManagerDidReceiveUpdates(for: blender)
            }
        }
    }
}
