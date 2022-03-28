//
//  ArbsVisSyncManager+Observation.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.03.2022.
//

import Foundation
import SwiftyJSON
import NetworkingModels
import Networking

/// Custom mechanism to observe socket events.
/// Created as an alternative to `NotificationCenter` to have more clear and swifty syntax
/// of adding observers with no need to parse object that raises an event.

/// Represents the object that can listen to folder actions.
protocol ArbsVisSyncObserver: AnyObject {
    func arbsVisSyncManagerDidReceiveArbMonth(manager: ArbsVisSyncInterface, arbVMonth: ArbVMonthSocket)
}

extension ArbsVisSyncObserver {

    func observeArbsVis(for uniqueIdentifier: String...) {

        for code in uniqueIdentifier {
            let observers = ArbsVisSyncManager.observers[code] ?? .init()
            observers.insert(self)
            ArbsVisSyncManager.observers[code] = observers
        }
    }

    func stopObservingArbsVis(for uniqueIdentifiers: String...) {

        for code in uniqueIdentifiers {
            guard let observers = ArbsVisSyncManager.observers[code] else { continue }
            observers.remove(self)
            ArbsVisSyncManager.observers[code] = observers
        }
    }

    func stopObservingAllArbsVisEvents() {

        for code in ArbsVisSyncManager.observers.keys {
            guard let observers = ArbsVisSyncManager.observers[code] else { continue }
            observers.remove(self)
            ArbsVisSyncManager.observers[code] = observers
        }
    }
}

extension ArbsVisSyncManager {

    /// Socket event observers.
    fileprivate static var observers: [String: WeakSet<ArbsVisSyncObserver>] = [:]

    func notifyObservers(about arbVMonth: ArbVMonthSocket, queue: OperationQueue = .main) {
        guard let observers = ArbsVisSyncManager.observers[arbVMonth.uniqueIdentifier]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.arbsVisSyncManagerDidReceiveArbMonth(manager: self, arbVMonth: arbVMonth) } }
    }
}

