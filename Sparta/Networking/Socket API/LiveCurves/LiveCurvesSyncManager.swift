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
    func liveCurvesSyncManagerDidChangeSyncDate(_ newDate: Date?)
}

class LiveCurvesSyncManager {

    // MARK: - Singleton

    static let intance = BlenderSyncManager()

    // MARK: - Public properties

    weak var delegate: LiveCurvesSyncManagerDelegate?

    private(set) var lastSyncDate: Date? {
        didSet {
            onMainThread {
                self.delegate?.liveCurvesSyncManagerDidChangeSyncDate(self.lastSyncDate)
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
    private var _liveCurves: [LiveCurve] = []

    private let excludedLiveCurvesCodes: [String] = ["SING92SPREADS", "RBOBFUTURESPREADS", "RBOBFUTURE", "DIFRBOBEXDUTY"]

    private let analyticsManager = AnalyticsNetworkManager()


    // MARK: - Initializers

    init() {
        observeSocket(for: .liveCurves)
    }

    // MARK: - Public methods

    func startReceivingData() {

        analyticsManager.fetchLiveCurves { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let responseModel) where responseModel.model != nil:

                let liveCurves = Array(responseModel.model!.list) //swiftlint:disable:this force_unwrapping

                onMainThread {
                    strongSelf.delegate?.liveCurvesSyncManagerDidFetch(liveCurves: liveCurves)
                }

                // socket connection

                App.instance.socketsConnect(toServer: .liveCurves)

            case .failure, .success:
                break
            }
        }
    }

    // MARK: - Private methods
}

extension LiveCurvesSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        var liveCurve = LiveCurve(json: data)

        guard !excludedLiveCurvesCodes.compactMap({ $0.lowercased() }).contains(liveCurve.name.lowercased()) else { return }

        lastSyncDate = Date()

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
