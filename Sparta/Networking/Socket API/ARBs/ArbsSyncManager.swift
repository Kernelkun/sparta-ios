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
    func arbsSyncManagerDidFetch(arbs: [Arb], profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?)
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

    private(set) var profile: ArbProfileCategory?

    var arbs: [Arb] {
        _arbs.arrayValue
    }

    // MARK: - Private properties

    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = .background
        return operationQueue
    }()
    private var _arbs: SynchronizedArray<Arb> = SynchronizedArray<Arb>()

    private(set) lazy var profiles = SynchronizedArray<ArbProfileCategory>()

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

            /*if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                favourites = Array(list)
            }*/

            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf._arbs = SynchronizedArray<Arb>(arbs)

            // patch new arb with current UI state
            for index in strongSelf._arbs.indices {
                strongSelf.patchArb(&strongSelf._arbs[index]!) //swiftlint:disable:this force_unwrapping
            }

            // load profiles

            let selectedProfile = strongSelf.profile

            let profiles = strongSelf._arbs.compactMap { $0.portfolio }.unique.compactMap { profile -> ArbProfileCategory in
                var profileCategory = ArbProfileCategory(portfolio: profile)

                /*let filteredArbs = arbs.filter { $0.portfolio == profile }.compactMap { arb -> Arb in
                    var arb = arb
                    strongSelf.patchArb(&arb)
                    return arb
                }*/

//                profileCategory.arbs = filteredArbs

                return profileCategory
            }

            strongSelf.profiles = SynchronizedArray(profiles)

            if selectedProfile != nil {
                strongSelf.profile = strongSelf.profiles.first { $0 == selectedProfile }!
            } else {
                strongSelf.profile = strongSelf.profiles.first.required()
            }


            onMainThread {
                strongSelf.updateArbs(for: strongSelf.profile.required())
//                strongSelf.updateBlenders(for: strongSelf.profile)
//                App.instance.socketsConnect(toServer: .blender)
            }

            strongSelf.lastSyncDate = Date()
        }
    }

    func setProfile(_ profile: ArbProfileCategory) {
        self.profile = profile
        updateArbs(for: profile)
    }

    func notifyAboutUpdated(arbMonth: ArbMonth) {
        if let arbIndex = _arbs.index(where: { $0.months.contains(arbMonth) }),
           let indexOfMonth = _arbs[arbIndex]!.months.firstIndex(of: arbMonth) { //swiftlint:disable:this force_unwrapping

            lastSyncDate = Date()

            _arbs[arbIndex]!.months[indexOfMonth].update(from: arbMonth) //swiftlint:disable:this force_unwrapping

            patchArb(&_arbs[arbIndex]!) //swiftlint:disable:this force_unwrapping

            notifyObservers(about: _arbs[arbIndex]!) //swiftlint:disable:this force_unwrapping

            onMainThread {
                self.delegate?.arbsSyncManagerDidReceiveUpdates(for: self._arbs[arbIndex]!) //swiftlint:disable:this force_unwrapping
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

    private func updateArbs(for profile: ArbProfileCategory) {
        onMainThread {
            self.delegate?.arbsSyncManagerDidFetch(arbs: self._arbs.filter { $0.portfolio == profile.portfolio },
                                                   profiles: self.profiles.arrayValue,
                                                   selectedProfile: profile)
        }
    }

    private func patchArb(_ newArb: inout Arb) {
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
