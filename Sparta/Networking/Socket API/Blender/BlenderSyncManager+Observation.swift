//
//  BlenderSyncManager+Observation.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 18.12.2020.
//

import Foundation
import SwiftyJSON
import NetworkingModels
import Networking

/// Custom mechanism to observe socket events.
/// Created as an alternative to `NotificationCenter` to have more clear and swifty syntax
/// of adding observers with no need to parse object that raises an event.

/// Represents the object that can listen to folder actions.
protocol BlenderObserver: class {
    func blenderDidReceiveResponse(for blenderMonth: BlenderMonth)
}

extension BlenderObserver {

    func observeBlenderMonth(for blendersMonthsNames: String...) {

        for name in blendersMonthsNames {
            let observers = BlenderSyncManager.observers[name] ?? .init()
            observers.insert(self)
            BlenderSyncManager.observers[name] = observers
        }
    }

    func stopObservingBlenderMonths(for blendersMonthsNames: String...) {

        for name in blendersMonthsNames {
            guard let observers = BlenderSyncManager.observers[name] else { continue }
            observers.remove(self)
            BlenderSyncManager.observers[name] = observers
        }
    }

    func stopObservingAllBlendersEvents() {

        for code in BlenderSyncManager.observers.keys {
            guard let observers = BlenderSyncManager.observers[code] else { continue }
            observers.remove(self)
            BlenderSyncManager.observers[code] = observers
        }
    }
}

extension BlenderSyncManager {

    /// Socket event observers.
    fileprivate static var observers: [String: WeakSet<BlenderObserver>] = [:]

    func notifyObservers(about blenderMonth: BlenderMonth, queue: OperationQueue = .main) {

        print("-observers count: \(BlenderSyncManager.observers.values.compactMap { $0.allObjects.count }.reduce(0, +))")

        guard let observers = BlenderSyncManager.observers[blenderMonth.observableName]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.blenderDidReceiveResponse(for: blenderMonth) } }
    }
}
