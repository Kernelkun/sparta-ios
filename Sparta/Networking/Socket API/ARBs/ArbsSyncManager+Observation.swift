//
//  ArbsSyncManager+Observation.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import Foundation
import SwiftyJSON
import NetworkingModels
import Networking

/// Custom mechanism to observe socket events.
/// Created as an alternative to `NotificationCenter` to have more clear and swifty syntax
/// of adding observers with no need to parse object that raises an event.

/// Represents the object that can listen to folder actions.
protocol ArbsObserver: class {
    func arbsDidReceiveResponse(for arb: Arb)
}

extension ArbsObserver {

    func observeArbs(_ arbs: Arb...) {

        for arb in arbs {
            let observers = ArbsSyncManager.observers[arb.uniqueIdentifier] ?? .init()
            observers.insert(self)
            ArbsSyncManager.observers[arb.uniqueIdentifier] = observers
        }
    }

    func stopObservingArbs(_ arbs: Arb...) {

        for arb in arbs {
            guard let observers = ArbsSyncManager.observers[arb.uniqueIdentifier] else { continue }
            observers.remove(self)
            ArbsSyncManager.observers[arb.uniqueIdentifier] = observers
        }
    }

    func stopObservingAllArbsEvents() {

        for code in ArbsSyncManager.observers.keys {
            guard let observers = ArbsSyncManager.observers[code] else { continue }
            observers.remove(self)
            ArbsSyncManager.observers[code] = observers
        }
    }
}

extension ArbsSyncManager {

    /// Socket event observers.
    fileprivate static var observers: [String: WeakSet<ArbsObserver>] = [:]

    func notifyObservers(about arb: Arb, queue: OperationQueue = .main) {

        print("-observers count: \(ArbsSyncManager.observers.values.compactMap { $0.allObjects.count }.reduce(0, +))")

        guard let observers = ArbsSyncManager.observers[arb.uniqueIdentifier]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.arbsDidReceiveResponse(for: arb) } }
    }
}
