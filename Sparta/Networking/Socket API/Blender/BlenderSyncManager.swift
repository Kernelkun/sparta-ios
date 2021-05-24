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
import SpartaHelpers

protocol BlenderSyncManagerDelegate: AnyObject {
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
    private var _blenders: SynchronizedArray<Blender> = SynchronizedArray<Blender>()
    private var _favourites: SynchronizedArray<Favourite> = SynchronizedArray<Favourite>()

    private let profileManager = ProfileNetworkManager()

    // MARK: - Initializers

    private init() {
        observeSocket(for: .blender)
    }

    // MARK: - Public methods

    func startReceivingData() {

        App.instance.socketsConnect(toServer: .blender)

        func startObservingSocketsEvents() {
            if !_blenders.isEmpty {

                let blenders = _blenders.compactMap { blender -> Blender in
                    var blender = blender
                    patchBlender(&blender)
                    return blender
                }

                _blenders = SynchronizedArray(blenders)

                onMainThread {
                    self.delegate?.blenderSyncManagerDidFetch(blenders: blenders)
                }
            }
        }

        profileManager.fetchBlenderFavouritesList { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                strongSelf._favourites = SynchronizedArray(list)
            }

            startObservingSocketsEvents()
        }
    }

    /*
     * Solution just for UI elements
     * Use when element wanted to fetch latest state of blender
     * In case method not found element in fetched elements array - method will return received(parameter variable) value
     */
    func fetchUpdatedState(for blender: Blender) -> Blender {
        guard let indexOfBlender = _blenders.index(where: { $0 == blender }) else { return blender }

        return _blenders[indexOfBlender] ?? blender
    }

    // MARK: - Favourite

    func updateFavouriteState(for blender: Blender) {

        // set up temporary value of favourite state for loaded blender
        if let currentBlenderIndex = _blenders.index(where: { $0 == blender }) {
            _blenders[currentBlenderIndex]?.isFavourite = blender.isFavourite
        }

        if blender.isFavourite {

            if !_favourites.contains(where: { $0.code == blender.serverUniqueIdentifier }) {

                // adding temporarry favourite value
                _favourites.append(.init(id: 1, code: blender.serverUniqueIdentifier))

                guard let userId = App.instance.currentUser?.id else { return }

                let blenderUniqueId = blender.serverUniqueIdentifier
                profileManager.addBlenderToFavouritesList(userId: userId, code: blenderUniqueId) { [weak self] result in
                    guard let strongSelf = self else { return }

                    // case if backside successfully add favourites record
                    if case let .success(responseModel) = result,
                       let model = responseModel.model,
                       let favouriteIndex = strongSelf._favourites.index(where: { $0.code == model.code }),
                       let blenderIndex = strongSelf._blenders.index(where: { $0 == blender }) {

                        strongSelf._favourites[favouriteIndex] = model
                    } else { // case if logic received bad response
                        let filteredFavourites = strongSelf._favourites.filter { $0.code != blender.serverUniqueIdentifier }
                        strongSelf._favourites = SynchronizedArray(filteredFavourites)

                        if let currentBlenderIndex = strongSelf._blenders.index(where: { $0.serverUniqueIdentifier == blender.serverUniqueIdentifier }) {
                            strongSelf._blenders[currentBlenderIndex]?.isFavourite = false
                        }
                    }
                }
            }
        } else if let index = _favourites.index(where: { $0.code == blender.serverUniqueIdentifier }) {

            let favouriteId = _favourites[index]!.id //swiftlint:disable:this force_unwrapping
            profileManager.deleteBlenderFromFavouritesList(id: favouriteId, completion: { [weak self] result in
                guard let strongSelf = self else { return }

                if case let .success(responseModel) = result,
                   responseModel.model != nil {

                    let filteredFavourites = strongSelf._favourites.filter { $0.code != blender.serverUniqueIdentifier }
                    strongSelf._favourites = SynchronizedArray(filteredFavourites)
                }
            })
        }
    }

    // MARK: - Private methods

    private func patchBlender(_ newBlender: inout Blender) {
        newBlender.isFavourite = _favourites.contains(where: { $0.code == newBlender.serverUniqueIdentifier })
        newBlender.priorityIndex = _blenders.index(where: { $0 == newBlender }) ?? -1
    }
}

extension BlenderSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        var blender = Blender(json: data)

        lastSyncDate = Date()

        if !_blenders.contains(blender) {

            _blenders.append(blender)
            patchBlender(&blender)

            onMainThread {
                self.delegate?.blenderSyncManagerDidReceive(blender: blender)
            }
        } else if let blenderIndex = _blenders.index(where: { $0 == blender }) {

            patchBlender(&blender)
            _blenders[blenderIndex] = blender

            onMainThread {
                self.delegate?.blenderSyncManagerDidReceiveUpdates(for: blender)
            }
        }

        // notify observers

        blender.months.forEach { notifyObservers(about: $0, queue: operationQueue) }
        notifyObserversAboutBlender(blender, queue: operationQueue)
    }
}
