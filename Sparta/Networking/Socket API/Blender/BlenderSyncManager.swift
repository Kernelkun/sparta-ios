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

    private(set) lazy var profile = profiles.first.required()

    // MARK: - Private properties

    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = .background
        return operationQueue
    }()
    private(set) lazy var profiles = SynchronizedArray<BlenderProfileCategory>([BlenderProfileCategory(portfolio: .ara),
                                                                                BlenderProfileCategory(portfolio: .houRefinery),
                                                                                BlenderProfileCategory(portfolio: .houBlender)
                                                                                ])
    private let networkManager = BlenderNetworkManager()

    // MARK: - Initializers

    private init() {
        observeSocket(for: .blender)
    }

    deinit {
        stopObservingSocket(for: .blender)
    }

    // MARK: - Public methods

    func start() {
        networkManager.fetchBlenderTable { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                // load profiles

                let selectedProfile = strongSelf.profile

                strongSelf.profiles = SynchronizedArray(strongSelf.profiles.compactMap { profile -> BlenderProfileCategory in
                    var profile = profile
                    profile.blenders = []

                    let filteredBlenders = list.filter { $0.portfolio == profile.portfolio }.compactMap { blender -> Blender in
                        var blender = blender
                        strongSelf.patchBlender(&blender)
                        return blender
                    }

                    for (index, blender) in filteredBlenders.enumerated() {
                        var blender = blender
                        blender.priorityIndex = index
                        profile.blenders.append(blender)
                    }

                    return profile
                })

                strongSelf.profile = strongSelf.profiles.first { $0 == selectedProfile }!

                onMainThread {
                    strongSelf.updateBlenders(for: strongSelf.profile)
                    App.instance.socketsConnect(toServer: .blender)
                }
            }
        }
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
        guard let indexOfProfile = profiles.index(where: { $0.portfolio == blender.portfolio }),
              let indexOfBlender = profiles[indexOfProfile]?.blenders.firstIndex(where: { $0 == blender }) else { return blender }

        return profiles[indexOfProfile]?.blenders[indexOfBlender] ?? blender
    }

    // MARK: - Private methods

    private func updateBlenders(for profile: BlenderProfileCategory) {
        onMainThread {
            self.delegate?.blenderSyncManagerDidFetch(blenders: self.profile.blenders,
                                                      profiles: self.profiles.arrayValue,
                                                      selectedProfile: self.profile)
        }
    }

    private func patchBlender(_ blender: inout Blender) {
        let month2Regions: [Blender.Portfolio] = [.houBlender, .houRefinery]
        if month2Regions.contains(blender.portfolio) {
            blender.months = Array(blender.months[0...1])
        }
    }
}

extension BlenderSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        var blender = Blender(json: data)

        lastSyncDate = Date()

        if let profileIndex = profiles.index(where: { $0.portfolio == blender.portfolio }),
           let blenderIndex = profiles[profileIndex]?.blenders.firstIndex(of: blender) {

            patchBlender(&blender)
            blender.priorityIndex = blenderIndex
            profiles[profileIndex]?.blenders[blenderIndex] = blender

            if blender.portfolio == profile.portfolio {
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
