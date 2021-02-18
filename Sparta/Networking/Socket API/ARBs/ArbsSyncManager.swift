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
import SpartaHelpers

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
    private var _arbs: SynchronizedArray<Arb> = SynchronizedArray<Arb>()
    private var _favourites: SynchronizedArray<Favourite> = SynchronizedArray<Favourite>()

    private let analyticsManager = AnalyticsNetworkManager()
    private let profileManager = ProfileNetworkManager()

    // MARK: - Initializers

    fileprivate init() {
        observeSocket(for: .arbs)
    }

    // MARK: - Public methods

    func startReceivingData() {

        let group = DispatchGroup()

        var arbs: [Arb] = []
        var favourites: [Favourite] = []

        group.enter()
        analyticsManager.fetchArbsTable { result in

            switch result {
            case .success(let responseModel) where responseModel.model != nil:
                arbs = Array(responseModel.model!.list)

            case .failure, .success:
                break
            }

            group.leave()
        }

        group.enter()
        profileManager.fetchArbsFavouritesList { result in

            switch result {
            case .success(let responseModel) where responseModel.model != nil:
                favourites = Array(responseModel.model!.list)

            case .failure, .success:
                break
            }

            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf._favourites = SynchronizedArray<Favourite>(favourites)
            strongSelf._arbs = SynchronizedArray<Arb>(arbs)

            // patch new arb with current UI state
            for index in strongSelf._arbs.indices {
                strongSelf.patchArb(&strongSelf._arbs[index]!)
            }

            strongSelf.delegate?.arbsSyncManagerDidFetch(arbs: strongSelf._arbs.compactMap { $0 })
            strongSelf.lastSyncDate = Date()

            // socket connection

            App.instance.socketsConnect(toServer: .arbs)
        }
    }

    func notifyAboutUpdated(arbMonth: ArbMonth) {
        if let arbIndex = _arbs.index(where: { $0.months.contains(arbMonth) }),
           let indexOfMonth = _arbs[arbIndex]!.months.firstIndex(of: arbMonth) {

            lastSyncDate = Date()

            _arbs[arbIndex]!.months[indexOfMonth].update(from: arbMonth)

            patchArb(&_arbs[arbIndex]!)

            notifyObservers(about: _arbs[arbIndex]!)

            onMainThread {
                self.delegate?.arbsSyncManagerDidReceiveUpdates(for: self._arbs[arbIndex]!)
            }
        }
    }

    // MARK: - Favourite

    func updateFavouriteState(for arb: Arb) {
        if arb.isFavourite {
            if !_favourites.contains(where: { $0.code == arb.serverUniqueIdentifier }) {
                _favourites.append(.init(id: 1, code: arb.serverUniqueIdentifier))

                guard let userId = App.instance.currentUser?.id else { return }

                profileManager.addArbToFavouritesList(userId: userId, code: arb.serverUniqueIdentifier) { [weak self] result in
                    guard let strongSelf = self else { return }

                    switch result {
                    case .success(let responseModel) where responseModel.model != nil:

                        if let index = strongSelf._favourites.index(where: { $0.code == responseModel.model!.code }) {
                            strongSelf._favourites[index] = responseModel.model
                        }

                    case .success, .failure:
                        break
                    }
                }
            }
        } else {
            if let index = _favourites.index(where: { $0.code == arb.serverUniqueIdentifier }) {
                profileManager.deleteArbFromFavouritesList(id: _favourites[index]!.id, completion: { _ in })

                _favourites = SynchronizedArray(_favourites.filter { $0.code != arb.serverUniqueIdentifier })
            }
        }
    }

    // MARK: - User TGT

    func updateUserTarget(_ userTarget: Double, for arbMonth: ArbMonth) {
        analyticsManager.updateArbUserTarget(userTarget, for: arbMonth) { [weak self] result in
            guard let strongSelf = self, result else { return }

            if let arbIndex = strongSelf._arbs.index(where: { $0.months.contains(arbMonth) }),
               let indexOfMonth = strongSelf._arbs[arbIndex]!.months.firstIndex(of: arbMonth) {

                strongSelf.lastSyncDate = Date()

                strongSelf._arbs[arbIndex]!.months[indexOfMonth].userTarget = userTarget

                strongSelf.notifyObservers(about: strongSelf._arbs[arbIndex]!)

                onMainThread {
                    strongSelf.delegate?.arbsSyncManagerDidReceiveUpdates(for: strongSelf._arbs[arbIndex]!)
                }
            }
        }
    }

    func deleteUserTarget(for arbMonth: ArbMonth) {
        analyticsManager.deleteArbUserTarget(for: arbMonth) { [weak self] result in
            guard let strongSelf = self, result else { return }

            if let arbIndex = strongSelf._arbs.index(where: { $0.months.contains(arbMonth) }),
               let indexOfMonth = strongSelf._arbs[arbIndex]!.months.firstIndex(of: arbMonth) {

                strongSelf.lastSyncDate = Date()

                strongSelf._arbs[arbIndex]!.months[indexOfMonth].userTarget = nil

                strongSelf.notifyObservers(about: strongSelf._arbs[arbIndex]!)

                onMainThread {
                    strongSelf.delegate?.arbsSyncManagerDidReceiveUpdates(for: strongSelf._arbs[arbIndex]!)
                }
            }
        }
    }

    // MARK: - Private methods

    private func patchArb(_ newArb: inout Arb) {
        newArb.isFavourite = _favourites.contains(where: { $0.code == newArb.serverUniqueIdentifier })
        newArb.priorityIndex = _arbs.index(where: { $0 == newArb }) ?? -1
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
