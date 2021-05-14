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
import SpartaHelpers

protocol LiveCurvesSyncManagerDelegate: AnyObject {
    func liveCurvesSyncManagerDidFetch(liveCurves: [LiveCurve])
    func liveCurvesSyncManagerDidReceive(liveCurve: LiveCurve)
    func liveCurvesSyncManagerDidReceiveUpdates(for liveCurve: LiveCurve)
    func liveCurvesSyncManagerDidChangeSyncDate(_ newDate: Date?)
}

class LiveCurvesSyncManager {

    // MARK: - Singleton

    static let intance = LiveCurvesSyncManager()

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
    private var _liveCurves = SynchronizedArray<LiveCurve>()

    private let analyticsManager = AnalyticsNetworkManager()

    // MARK: - Initializers

    private init() {
        observeSocket(for: .liveCurves)
    }

    // MARK: - Public methods

    func startReceivingData() {

        analyticsManager.fetchLiveCurves { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let responseModel) where responseModel.model != nil:

                let liveCurves = Array(responseModel.model!.list) //swiftlint:disable:this force_unwrapping
                strongSelf._liveCurves = SynchronizedArray(liveCurves)

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

        let liveCurveSocket = LiveCurveSocket(json: data)

        // check if app received price update
        guard liveCurveSocket.socketType == .priceUpdate else { return }

        lastSyncDate = Date()

        let liveCurvePrice = LiveCurvePrice(json: liveCurveSocket.payload)

        // check if current array consist live curve with specific code
        guard let liveCurveIndex = _liveCurves.index(where: { $0.code == liveCurvePrice.code
                                                        && $0.monthCode == liveCurvePrice.periodCode }),
              LiveCurve.months.contains(liveCurvePrice.periodCode),
              var liveCurve = _liveCurves[liveCurveIndex] else { return }

        let oldPrice = liveCurve.priceValue
        let newPrice = liveCurvePrice.priceValue

        if oldPrice > newPrice {
            liveCurve.state = .down

            _liveCurves[liveCurveIndex] = liveCurve
            notifyObservers(about: liveCurve, queue: operationQueue)
        } else if oldPrice < newPrice {
            liveCurve.state = .up

            _liveCurves[liveCurveIndex] = liveCurve
            notifyObservers(about: liveCurve, queue: operationQueue)
        }

        onMainThread {
            self.delegate?.liveCurvesSyncManagerDidReceiveUpdates(for: liveCurve)
        }
    }
}
