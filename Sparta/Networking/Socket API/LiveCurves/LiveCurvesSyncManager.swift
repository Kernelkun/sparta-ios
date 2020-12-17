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
    func liveCurvesSyncManagerDidReceive(liveCurve: LiveCurve)
    func liveCurvesSyncManagerDidReceiveUpdates(for liveCurve: LiveCurve)
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

    func startReceivingData() {

        App.instance.socketsConnect(toServer: .liveCurves)

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

        if !_liveCurves.contains(liveCurve) {
            _liveCurves.append(liveCurve)

            onMainThread {
                self.delegate?.liveCurvesSyncManagerDidReceive(liveCurve: liveCurve)
            }
        } else if let liveCurveIndex = _liveCurves.firstIndex(of: liveCurve) {
            _liveCurves[liveCurveIndex] = liveCurve

            onMainThread {
                self.delegate?.liveCurvesSyncManagerDidReceiveUpdates(for: liveCurve)
            }
        }

        notifyObservers(about: liveCurve)
    }
}
