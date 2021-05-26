//
//  LiveCurvesSyncManager+Observation.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.12.2020.
//

import Foundation
import SwiftyJSON
import NetworkingModels
import Networking

/// Custom mechanism to observe socket events.
/// Created as an alternative to `NotificationCenter` to have more clear and swifty syntax
/// of adding observers with no need to parse object that raises an event.

/// Represents the object that can listen to folder actions.
protocol LiveCurvesObserver: AnyObject {
    func liveCurvesDidReceiveResponse(for liveCurve: LiveCurve)
}

extension LiveCurvesObserver {

    func observeLiveCurves(for priceCodes: String...) {

        for code in priceCodes {
            let observers = LiveCurvesSyncManager.observers[code] ?? .init()
            observers.insert(self)
            LiveCurvesSyncManager.observers[code] = observers
        }
    }

    func stopObservingLiveCurves(for priceCodes: String...) {

        for code in priceCodes {
            guard let observers = LiveCurvesSyncManager.observers[code] else { continue }
            observers.remove(self)
            LiveCurvesSyncManager.observers[code] = observers
        }
    }

    func stopObservingAllLiveCurvesEvents() {

        for code in LiveCurvesSyncManager.observers.keys {
            guard let observers = LiveCurvesSyncManager.observers[code] else { continue }
            observers.remove(self)
            LiveCurvesSyncManager.observers[code] = observers
        }
    }
}

extension LiveCurvesSyncManager {

    /// Socket event observers.
    fileprivate static var observers: [String: WeakSet<LiveCurvesObserver>] = [:]

    func notifyObservers(about liveCurve: LiveCurve, queue: OperationQueue = .main) {

        print("-observers count: \(LiveCurvesSyncManager.observers.values.compactMap { $0.allObjects.count }.reduce(0, +))")

        guard let observers = LiveCurvesSyncManager.observers[liveCurve.priceCode]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.liveCurvesDidReceiveResponse(for: liveCurve) } }
    }
}
