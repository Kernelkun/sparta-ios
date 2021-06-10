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

    /// Add profile to list. This method will not send request to server.
    func addProfile(_ profile: LiveCurveProfileCategory, makeActive: Bool)

    /// Remove specific profile
    func removeProfile(_ profile: LiveCurveProfileCategory)
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
        filteredProfileLiveCurves()
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

            strongSelf._profiles = SynchronizedArray(fetchedProfiles)
            strongSelf._liveCurves = SynchronizedArray(fetchedLiveCurves)
            strongSelf.updateProfiles()

            // socket connection

            App.instance.socketsConnect(toServer: .liveCurves)
        }
    }

    func setProfile(_ profile: LiveCurveProfileCategory) {
        self.profile = profile
        updateLiveCurves(for: profile)
    }

    func addProfile(_ profile: LiveCurveProfileCategory, makeActive: Bool) {
        _profiles.append(profile)

        if makeActive {
            setProfile(profile)
        }
    }

    func removeProfile(_ profile: LiveCurveProfileCategory) {
        guard _profiles.count > 1 else { return }

        _profiles = SynchronizedArray(_profiles.filter { $0 != profile })

        networkManager.deletePortfolio(id: profile.id, completion: { _ in })

        if self.profile == profile {
            self.profile = _profiles.last
        }

        updateProfiles()
    }

    // MARK: - Private methods

    private func updateLiveCurves(for profile: LiveCurveProfileCategory) {
        onMainThread {
            self.delegate?.liveCurvesSyncManagerDidFetch(liveCurves: self.filteredProfileLiveCurves(),
                                                         profiles: self._profiles.arrayValue,
                                                         selectedProfile: profile)
        }
    }

    private func updateProfiles() {
        if profile == nil, let defaultProfile = _profiles.first {
            setProfile(defaultProfile)
        } else if let selectedProfile = profile, let updatedProfile = _profiles.first(where: { $0.id == selectedProfile.id }) {
            setProfile(updatedProfile)
        } else if let firstProfile = _profiles.first {
            setProfile(firstProfile)
        }
    }

    private func filteredProfileLiveCurves() -> [LiveCurve] {
        guard let profile = profile else { return [] }

        return _liveCurves.compactMap { liveCurve -> LiveCurve? in
            guard let liveCurveItem = profile.liveCurves.first(where: { $0.code == liveCurve.code }) else { return nil }

            var liveCurve = liveCurve
            liveCurve.priorityIndex = liveCurveItem.order

            return liveCurve
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
