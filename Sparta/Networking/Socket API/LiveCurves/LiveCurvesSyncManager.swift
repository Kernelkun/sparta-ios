//
//  LiveCurvesSyncManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.12.2020.
//

import Foundation
import SwiftyJSON
import Networking
import NetworkingModels

protocol LiveCurvesSyncManagerDelegate: class {
    func liveCurvesSyncManagerDidFetch(liveCurves: [LiveCurve])
    func liveCurvesSyncManagerDidReceive(liveCurve: LiveCurve)
    func liveCurvesSyncManagerDidReceiveUpdates(for liveCurve: LiveCurve)
}

class LiveCurvesSyncManager {

    // MARK: - Singleton

    static let intance = BlenderSyncManager()

    // MARK: - Public properties

    weak var delegate: LiveCurvesSyncManagerDelegate?

    // MARK: - Private properties

    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = .background
        return operationQueue
    }()
    private var _liveCurves: [LiveCurve] = []

    private let excludedLiveCurvesCodes: [String] = ["SING92SPREADS", "RBOBFUTURESPREADS", "RBOBFUTURE", "DIFRBOBEXDUTY"]

    // MARK: - Initializers

    init() {
        observeSocket(for: .liveCurves)
    }

    // MARK: - Public methods

    func startReceivingData() {

        App.instance.socketsConnect(toServer: .liveCurves)

        if !_liveCurves.isEmpty {
            let liveCurves = Array(_liveCurves)

            delegate?.liveCurvesSyncManagerDidFetch(liveCurves: liveCurves)
        }
    }

    // MARK: - Private methods
}

extension LiveCurvesSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        var liveCurve = LiveCurve(json: data)

        guard !excludedLiveCurvesCodes.compactMap({ $0.lowercased() }).contains(liveCurve.name.lowercased()) else { return }

        if !_liveCurves.contains(liveCurve) {
            _liveCurves.append(liveCurve)

            notifyObservers(about: liveCurve, queue: operationQueue)

            onMainThread {
                self.delegate?.liveCurvesSyncManagerDidReceive(liveCurve: liveCurve)
            }
        } else if let liveCurveIndex = _liveCurves.firstIndex(of: liveCurve) {

            let oldLiveCurve = _liveCurves[liveCurveIndex]

            if oldLiveCurve.priceCode > liveCurve.priceCode {
                liveCurve.state = .down
            } else if oldLiveCurve.priceCode < liveCurve.priceCode {
                liveCurve.state = .up
            }

            if liveCurve.state != .initial {
                _liveCurves[liveCurveIndex] = liveCurve
                notifyObservers(about: liveCurve, queue: operationQueue)
            }

            onMainThread {
                self.delegate?.liveCurvesSyncManagerDidReceiveUpdates(for: liveCurve)
            }
        }
    }
}
