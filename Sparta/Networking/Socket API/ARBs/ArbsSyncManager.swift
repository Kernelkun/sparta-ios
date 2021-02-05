//
//  ArbsSyncManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.12.2020.
//

import Foundation
import SwiftyJSON
import Networking
import NetworkingModels

protocol ArbsSyncManagerDelegate: class {
    func arbsSyncManagerDidFetch(arbs: [Arb])
    func arbsSyncManagerDidReceive(arb: Arb)
    func arbsSyncManagerDidReceiveUpdates(for arb: Arb)
    func arbsSyncManagerDidChangeSyncDate(_ newDate: Date?)
}

class ArbsSyncManager {

    // MARK: - Singleton

    static let intance = ArbsSyncManager()

    // MARK: - Public properties

    weak var delegate: ArbsSyncManagerDelegate?

    private(set) var lastSyncDate: Date? {
        didSet {
            onMainThread {
                self.delegate?.arbsSyncManagerDidChangeSyncDate(self.lastSyncDate)
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
    private var _arbs: [Arb] = []

    private let analyticsManager = AnalyticsNetworkManager()

    // MARK: - Initializers

    fileprivate init() {
        observeSocket(for: .arbs)
    }

    // MARK: - Public methods

    func startReceivingData() {

        analyticsManager.fetchArbsTable { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let responseModel) where responseModel.model != nil:

                strongSelf._arbs = Array(responseModel.model!.list) //swiftlint:disable:this force_unwrapping

                onMainThread {
                    strongSelf.delegate?.arbsSyncManagerDidFetch(arbs: strongSelf._arbs)
                }

                strongSelf.lastSyncDate = Date()

                // socket connection

                App.instance.socketsConnect(toServer: .arbs)

            case .failure, .success:
                break
            }
        }
    }

    func notifyAboutUpdated(arbMonth: ArbMonth) {
        if let arbIndex = _arbs.firstIndex(where: { $0.months.contains(arbMonth) }),
           let indexOfMonth = _arbs[arbIndex].months.firstIndex(of: arbMonth) {

            lastSyncDate = Date()

            _arbs[arbIndex].months[indexOfMonth].update(from: arbMonth)

            notifyObservers(about: _arbs[arbIndex])

            onMainThread {
                self.delegate?.arbsSyncManagerDidReceiveUpdates(for: self._arbs[arbIndex])
            }
        }
    }
}
extension ArbsSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        let arbSocket = ArbSocket(json: data)

        guard arbSocket.socketType == .arbMonth else { return }

        let arbMonth = ArbMonth(json: arbSocket.payload)

        notifyAboutUpdated(arbMonth: arbMonth)
    }
}
