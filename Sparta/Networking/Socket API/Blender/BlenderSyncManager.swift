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
    func blenderSyncManagerDidFetch(blenders: [Blender], profiles: [BlenderProfileCategory], selectedProfile: BlenderProfileCategory?)
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

    private(set) lazy var profile: BlenderProfileCategory = _profiles.first! //swiftlint:disable:this force_unwrapping

    // MARK: - Private properties

    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = .background
        return operationQueue
    }()
    private var _blenders: SynchronizedArray<Blender> = SynchronizedArray<Blender>()
    private lazy var _profiles = SynchronizedArray<BlenderProfileCategory>([BlenderProfileCategory(region: .ara),
                                                                            BlenderProfileCategory(region: .hou)])
    private let profileManager = ProfileNetworkManager()

    // MARK: - Initializers

    private init() {
        observeSocket(for: .blender)
    }

    // MARK: - Public methods

    func startReceivingData() {
        updateBlenders(for: profile)
        App.instance.socketsConnect(toServer: .blender)
    }

    func setProfile(_ profile: BlenderProfileCategory) {
        self.profile = profile
        updateBlenders(for: profile)
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

    // MARK: - Private methods

    private func patchBlender(_ newBlender: inout Blender) {
        newBlender.priorityIndex = _blenders.index(where: { $0 == newBlender }) ?? -1
    }

    private func updateBlenders(for profile: BlenderProfileCategory) {
        onMainThread {
            self.delegate?.blenderSyncManagerDidFetch(blenders: self.filteredProfileBlenders(),
                                                      profiles: self._profiles.arrayValue,
                                                      selectedProfile: self.profile)
        }
    }

    private func filteredProfileBlenders() -> [Blender] {
        _blenders.filter { $0.loadRegion == profile.region }
    }
}

extension BlenderSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        var blender = Blender(json: data)

        lastSyncDate = Date()

        if !_blenders.contains(blender) {

            _blenders.append(blender)
            patchBlender(&blender)

            if blender.loadRegion == profile.region {
                onMainThread {
                    self.delegate?.blenderSyncManagerDidReceive(blender: blender)
                }
            }
        } else if let blenderIndex = _blenders.index(where: { $0 == blender }) {

            patchBlender(&blender)
            _blenders[blenderIndex] = blender

            if blender.loadRegion == profile.region {
                onMainThread {
                    self.delegate?.blenderSyncManagerDidReceiveUpdates(for: blender)
                }
            }
        }

        // notify observers

        blender.months.forEach { notifyObservers(about: $0, queue: operationQueue) }
        notifyObserversAboutBlender(blender, queue: operationQueue)
    }
}
