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

protocol ArbsSyncManagerDelegate: AnyObject {
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

    private let arbsManager = ArbsNetworkManager()
    private let profileManager = ProfileNetworkManager()

    // MARK: - Initializers

    fileprivate init() {
        observeSocket(for: .arbs)
    }

    // MARK: - Public methods

    func startReceivingData() {

        // socket connection

        App.instance.socketsConnect(toServer: .arbs)

        // fetch main data
        
        let group = DispatchGroup()

        var arbs: [Arb] = []
        var favourites: [Favourite] = []

        group.enter()
        arbsManager.fetchArbsTable { result in

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                arbs = Array(list)
            }

            group.leave()
        }

        group.enter()
        profileManager.fetchArbsFavouritesList { result in

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                favourites = Array(list)
            }

            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf._favourites = SynchronizedArray<Favourite>(favourites)
            strongSelf._arbs = SynchronizedArray<Arb>(arbs)

            // patch new arb with current UI state
            for index in strongSelf._arbs.indices {
                strongSelf.patchArb(&strongSelf._arbs[index]!) //swiftlint:disable:this force_unwrapping
            }

            strongSelf.delegate?.arbsSyncManagerDidFetch(arbs: strongSelf._arbs.compactMap { $0 })
            strongSelf.lastSyncDate = Date()
        }
    }

    func notifyAboutUpdated(arbMonth: ArbMonth) {
        if let arbIndex = _arbs.index(where: { $0.months.contains(arbMonth) }),
           let indexOfMonth = _arbs[arbIndex]!.months.firstIndex(of: arbMonth) { //swiftlint:disable:this force_unwrapping

            lastSyncDate = Date()

            _arbs[arbIndex]!.months[indexOfMonth].update(from: arbMonth) //swiftlint:disable:this force_unwrapping

            patchArb(&_arbs[arbIndex]!) //swiftlint:disable:this force_unwrapping

            notifyObservers(about: _arbs[arbIndex]!) //swiftlint:disable:this force_unwrapping

            onMainThread {
                self.delegate?.arbsSyncManagerDidReceiveUpdates(for: self._arbs[arbIndex]!) //swiftlint:disable:this line_length
            }
        }
    }

    /*
     * Solution just for UI elements
     * Use when element wanted to fetch latest state of arb
     * In case method not found element in fetched elements array - method will return received(parameter variable) value
     */
    func fetchUpdatedState(for arb: Arb) -> Arb {
        guard let indexOfArb = _arbs.index(where: { $0.uniqueIdentifier == arb.uniqueIdentifier }) else { return arb }

        return _arbs[indexOfArb] ?? arb
    }

    // MARK: - Favourite

    func updateFavouriteState(for arb: Arb) {

        // set up temporary value of favourite state for loaded arb
        if let currentArbIndex = _arbs.index(where: { $0.uniqueIdentifier == arb.uniqueIdentifier }) {
            _arbs[currentArbIndex]?.isFavourite = arb.isFavourite
        }

        if arb.isFavourite {

            if !_favourites.contains(where: { $0.code == arb.serverUniqueIdentifier }) {

                // adding temporarry favourite value
                _favourites.append(.init(id: 1, code: arb.serverUniqueIdentifier))

                guard let userId = App.instance.currentUser?.id else { return }

                profileManager.addArbToFavouritesList(userId: userId, code: arb.serverUniqueIdentifier) { [weak self] result in
                    guard let strongSelf = self else { return }

                    // case if backside successfully add favourites record
                    if case let .success(responseModel) = result,
                       let model = responseModel.model,
                       let favouriteIndex = strongSelf._favourites.index(where: { $0.code == model.code }),
                       let arbIndex = strongSelf._arbs.index(where: { $0.uniqueIdentifier == arb.uniqueIdentifier }) {

                        strongSelf._favourites[favouriteIndex] = model
                        strongSelf._arbs[arbIndex]?.isFavourite = true
                    } else { // case if logic received bad response
                        strongSelf._favourites = SynchronizedArray(strongSelf._favourites.filter { $0.code != arb.serverUniqueIdentifier })

                        if let currentArbIndex = strongSelf._arbs.index(where: { $0.uniqueIdentifier == arb.uniqueIdentifier }) {
                            strongSelf._arbs[currentArbIndex]?.isFavourite = false
                        }
                    }
                }
            }
        } else if let index = _favourites.index(where: { $0.code == arb.serverUniqueIdentifier }) {

            profileManager.deleteArbFromFavouritesList(id: _favourites[index]!.id, completion: { [weak self] result in
                guard let strongSelf = self else { return }

                if case let .success(responseModel) = result,
                   responseModel.model != nil {

                    strongSelf._favourites = SynchronizedArray(strongSelf._favourites.filter { $0.code != arb.serverUniqueIdentifier })
                }
            })
        }
    }

    // MARK: - User TGT

    func updateUserTarget(_ userTarget: Double, for arbMonth: ArbMonth) {
        arbsManager.updateArbUserTarget(userTarget, for: arbMonth) { [weak self] result in
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
        arbsManager.deleteArbUserTarget(for: arbMonth) { [weak self] result in
            guard let strongSelf = self, result else { return }

            if let arbIndex = strongSelf._arbs.index(where: { $0.months.contains(arbMonth) }),
               let indexOfMonth = strongSelf._arbs[arbIndex]?.months.firstIndex(of: arbMonth) {

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
