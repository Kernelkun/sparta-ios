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

protocol LiveCurvesSyncManagerDelegate: class {
    func liveCurvesSyncManagerDidFetch(liveCurves: [LiveCurve])
    func liveCurvesSyncManagerDidReceive(liveCurves: LiveCurve)
    func liveCurvesSyncManagerDidReceiveUpdates(for liveCurves: LiveCurve)
}

class LiveCurvesSyncManager {

    // MARK: - Singleton

    static let intance = BlenderSyncManager()

    // MARK: - Public properties

    weak var delegate: LiveCurvesSyncManagerDelegate?

    // MARK: - Private properties

    private var _liveCurves: [LiveCurve] = []

    // MARK: - Initializers

    init() {
        observeSocket(for: .liveCurves)
    }

    // MARK: - Public methods

    func startSilentLoading() {

    }

    func loadData() {

        if !_liveCurves.isEmpty {
            let liveCurves = Array(_liveCurves)

            delegate?.liveCurvesSyncManagerDidFetch(liveCurves: liveCurves)
        }
    }

    // MARK: - Private methods
}

extension LiveCurvesSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {

        let liveCurve = LiveCurve(json: data)

        print(liveCurve)

        /*if !_blenders.contains(blender) {
            _blenders.append(blender)

            onMainThread {
                self.delegate?.blenderSyncManagerDidReceive(blender: blender)
            }
        } else if let blenderIndex = _blenders.firstIndex(of: blender) {
            _blenders[blenderIndex] = blender

            onMainThread {
                self.delegate?.blenderSyncManagerDidReceiveUpdates(for: blender)
            }
        }*/
    }
}
