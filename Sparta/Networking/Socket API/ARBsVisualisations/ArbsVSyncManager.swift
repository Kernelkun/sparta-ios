//
//  ArbsVSyncManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.11.2021.
//

import Foundation
import SwiftyJSON
import Networking
import NetworkingModels
import SpartaHelpers

/*protocol ArbsSyncManagerDelegate: AnyObject {
    func arbsSyncManagerDidFetch(arbs: [Arb], profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?)
    func arbsSyncManagerDidReceive(arb: Arb)
    func arbsSyncManagerDidReceiveUpdates(for arb: Arb)
    func arbsSyncManagerDidChangeSyncDate(_ newDate: Date?)
}*/

class ArbsVSyncManager: ArbsVSyncManagerProtocol {

    // MARK: - Public properties

//    weak var delegate: ArbsSyncManagerDelegate?

    // MARK: - Private properties

    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = .background
        return operationQueue
    }()

    // MARK: - Initializers

    init() {
        observeSocket(for: .visualisations)
    }

    deinit {
        stopObservingSocket(for: .visualisations)
    }

    // MARK: - Public methods

    func start() {

        // socket connection

        App.instance.socketsConnect(toServer: .visualisations)
    }

    func notifyAboutUpdated(_ arbVSocket: ArbV.Socket) {
        /*if let arbIndex = _arbs.index(where: { $0.months.contains(arbMonth) }), 
           let indexOfMonth = _arbs[arbIndex]!.months.firstIndex(of: arbMonth) { //swiftlint:disable:this force_unwrapping

            lastSyncDate = Date()

            _arbs[arbIndex]!.months[indexOfMonth].update(from: arbMonth) //swiftlint:disable:this force_unwrapping

            patchArb(&_arbs[arbIndex]!) //swiftlint:disable:this force_unwrapping

            notifyObservers(about: _arbs[arbIndex]!) //swiftlint:disable:this force_unwrapping

            onMainThread {
                self.delegate?.arbsSyncManagerDidReceiveUpdates(for: self._arbs[arbIndex]!) //swiftlint:disable:this force_unwrapping
            }
        }*/
    }
}
extension ArbsVSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {
        let arbSocket = ArbSocket(json: data)

        guard arbSocket.socketType == .arbMonth else { return }

        let arbVSocket = ArbV.Socket(json: arbSocket.payload)
        notifyAboutUpdated(arbVSocket)
    }
}
