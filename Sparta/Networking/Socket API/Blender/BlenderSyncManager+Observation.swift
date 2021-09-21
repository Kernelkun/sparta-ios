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
protocol BlenderObserver: AnyObject {
    func blenderDidReceiveResponse(for blenderMonth: BlenderMonth)
    func blenderDidReceiveUpdates(_ blender: Blender)
}

extension BlenderObserver {
    func blenderDidReceiveResponse(for blenderMonth: BlenderMonth) {}
    func blenderDidReceiveUpdates(_ blender: Blender) {}
}

extension BlenderObserver {

    // months

    func observeBlenderMonth(for blendersMonthsNames: String...) {

        for name in blendersMonthsNames {
            let observers = BlenderSyncManager.monthsObservers[name] ?? .init()
            observers.insert(self)
            BlenderSyncManager.monthsObservers[name] = observers
        }
    }

    func stopObservingBlenderMonths(for blendersMonthsNames: String...) {

        for name in blendersMonthsNames {
            guard let observers = BlenderSyncManager.monthsObservers[name] else { continue }
            observers.remove(self)
            BlenderSyncManager.monthsObservers[name] = observers
        }
    }

    func stopObservingAllBlendersMonthsEvents() {

        for code in BlenderSyncManager.monthsObservers.keys {
            guard let observers = BlenderSyncManager.monthsObservers[code] else { continue }
            observers.remove(self)
            BlenderSyncManager.monthsObservers[code] = observers
        }
    }

    // blenders

    func observeBlenders(_ blenders: Blender...) {

        for blender in blenders {
            let observers = BlenderSyncManager.blenderObservers[blender.serverUniqueIdentifier] ?? .init()
            observers.insert(self)
            BlenderSyncManager.blenderObservers[blender.serverUniqueIdentifier] = observers
        }
    }

    func stopObservingBlenders(for blenders: Blender...) {

        for blender in blenders {
            guard let observers = BlenderSyncManager.blenderObservers[blender.serverUniqueIdentifier] else { continue }
            observers.remove(self)
            BlenderSyncManager.blenderObservers[blender.serverUniqueIdentifier] = observers
        }
    }

    func stopObservingAllBlendersEvents() {

        for code in BlenderSyncManager.blenderObservers.keys {
            guard let observers = BlenderSyncManager.blenderObservers[code] else { continue }
            observers.remove(self)
            BlenderSyncManager.blenderObservers[code] = observers
        }
    }
}

extension BlenderSyncManager {

    /// Socket event observers.
    fileprivate static var monthsObservers: [String: WeakSet<BlenderObserver>] = [:]
    fileprivate static var blenderObservers: [String: WeakSet<BlenderObserver>] = [:]

    func notifyObservers(about blenderMonth: BlenderMonth, queue: OperationQueue = .main) {

        print("-observers count: \(BlenderSyncManager.monthsObservers.values.compactMap { $0.allObjects.count }.reduce(0, +))")

        guard let observers = BlenderSyncManager.monthsObservers[blenderMonth.observableName]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.blenderDidReceiveResponse(for: blenderMonth) } }
    }

    func notifyObserversAboutBlender(_ blender: Blender, queue: OperationQueue = .main) {

        print("-observers count: \(BlenderSyncManager.blenderObservers.values.compactMap { $0.allObjects.count }.reduce(0, +))")

        guard let observers = BlenderSyncManager.blenderObservers[blender.serverUniqueIdentifier]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.blenderDidReceiveUpdates(blender) } }
    }
}
