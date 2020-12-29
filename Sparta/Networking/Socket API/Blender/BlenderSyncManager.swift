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
    func blenderSyncManagerDidFetch(blenders: [Blender])
    func blenderSyncManagerDidReceive(blender: Blender)
    func blenderSyncManagerDidReceiveUpdates(for blender: Blender)
    func blenderSyncManagerDidChangeSyncDate(_ newDate: Date?)
}

class BlenderSyncManager {

    // MARK: - Singleton

    static let intance = BlenderSyncManager()

    // MARK: - Public properties

    weak var delegate: BlenderSyncManagerDelegate?

    private(set) var lastSyncDate: Date? {
        didSet {
            onMainThread {
                self.delegate?.blenderSyncManagerDidChangeSyncDate(self.lastSyncDate)
            }
        }
    }

    // MARK: - Private properties

    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = .background
        return operationQueue
    }()
    private var _blenders: [Blender] = []

    // MARK: - Initializers

    init() {
        observeSocket(for: .blender)
    }

    // MARK: - Public methods

    func startReceivingData() {

        App.instance.socketsConnect(toServer: .blender)

        if !_blenders.isEmpty {
            let blenders = Array(_blenders)

            delegate?.blenderSyncManagerDidFetch(blenders: blenders)
        }
    }

    // MARK: - Private methods
}

extension BlenderSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        let blender = Blender(json: data)

        lastSyncDate = Date()

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

        // notify observers

        blender.months.forEach { notifyObservers(about: $0, queue: operationQueue) }
    }
}
