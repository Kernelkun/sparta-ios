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
    func liveCurvesSyncManagerDidFetch(liveCurves: [LiveCurve], profiles: [LiveCurveProfileCategory], selectedProfile: LiveCurveProfileCategory?)
    func liveCurvesSyncManagerDidReceive(liveCurve: LiveCurve)
    func liveCurvesSyncManagerDidReceiveUpdates(for liveCurve: LiveCurve)
    func liveCurvesSyncManagerDidChangeSyncDate(_ newDate: Date?)
}

protocol LiveCurvesSyncManagerProtocol {
    /// Notification delegate
    var delegate: LiveCurvesSyncManagerDelegate? { get set }

    /// Last date when manager received any updates
    var lastSyncDate: Date? { get }

    /// Current live curves
    var liveCurves: [LiveCurve] { get }

    /// Current live curves matched with selected profile
    var profileLiveCurves: [LiveCurve] { get }

    /// Current selected profile
    var profile: LiveCurveProfileCategory? { get }

    /// Launch service. To receive any updates need to use this method
    func start()

    /// Change profile setting
    func setProfile(_ profile: LiveCurveProfileCategory)
}

class LiveCurvesSyncManager: LiveCurvesSyncManagerProtocol {

    // MARK: - Public properties

    weak var delegate: LiveCurvesSyncManagerDelegate?

    private(set) var lastSyncDate: Date? {
        didSet {
            onMainThread {
                self.delegate?.liveCurvesSyncManagerDidChangeSyncDate(self.lastSyncDate)
            }
        }
    }

    private(set) var profile: LiveCurveProfileCategory?

    var liveCurves: [LiveCurve] {
        _liveCurves.arrayValue
    }

    var profileLiveCurves: [LiveCurve] {
        guard let profile = profile else { return [] }

        return liveCurves.filter { profile.contains(liveCurve: $0) }
    }

    // MARK: - Private properties

    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = .background
        return operationQueue
    }()
    private var _liveCurves = SynchronizedArray<LiveCurve>()
    private var _profiles = SynchronizedArray<LiveCurveProfileCategory>()
    private let networkManager = LiveCurvesNetworkManager()

    // MARK: - Initializers

    init() {
        observeSocket(for: .liveCurves)
    }

    deinit {
        stopObservingSocket(for: .liveCurves)
    }

    // MARK: - Public methods

    func start() {
        let dispatchGroup = DispatchGroup()

        var fetchedProfiles: [LiveCurveProfileCategory] = []
        var fetchedLiveCurves: [LiveCurve] = []

        dispatchGroup.enter()
        networkManager.fetchPortfolios { result in

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                fetchedProfiles = list
            }

            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        networkManager.fetchLiveCurves { result in

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                fetchedLiveCurves = list
            }

            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }

            // profiles

            strongSelf._profiles = SynchronizedArray(fetchedProfiles)

            // main models

            let liveCurves = fetchedLiveCurves.compactMap { liveCurve -> LiveCurve in
                var liveCurve = liveCurve
                liveCurve.priorityIndex = fetchedLiveCurves.firstIndex(of: liveCurve) ?? -1
                return liveCurve
            }
            strongSelf._liveCurves = SynchronizedArray(liveCurves)

            if strongSelf.profile == nil, let defaultProfile = fetchedProfiles.first {
                strongSelf.setProfile(defaultProfile)
            } else if let selectedProfile = strongSelf.profile {
                strongSelf.setProfile(selectedProfile)
            }

            // socket connection

            App.instance.socketsConnect(toServer: .liveCurves)
        }
    }

    func setProfile(_ profile: LiveCurveProfileCategory) {
        self.profile = profile
        updateLiveCurves(for: profile)
    }

    // MARK: - Private methods

    private func updateLiveCurves(for profile: LiveCurveProfileCategory) {
        let filteredLiveCurves = _liveCurves.filter { profile.contains(liveCurve: $0) }

        onMainThread {
            self.delegate?.liveCurvesSyncManagerDidFetch(liveCurves: filteredLiveCurves,
                                                         profiles: self._profiles.arrayValue,
                                                         selectedProfile: profile)
        }
    }
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
              var liveCurve = _liveCurves[liveCurveIndex] else { return }

        let oldPrice = liveCurve.priceValue
        let newPrice = liveCurvePrice.priceValue

        liveCurve.priceValue = newPrice

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
