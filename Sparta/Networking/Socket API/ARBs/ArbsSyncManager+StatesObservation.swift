//
//  ArbsSyncManager+StatesObservation.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.11.2021.
//

import Foundation
import SwiftyJSON
import NetworkingModels
import Networking

/// Custom mechanism to observe socket events.
/// Created as an alternative to `NotificationCenter` to have more clear and swifty syntax
/// of adding observers with no need to parse object that raises an event.

/// Represents the object that can listen to folder actions.
protocol ArbsSyncManagerObserver: AnyObject {
    func arbsSyncManagerDidChangeLoadingState(_ isLoading: Bool)
    func arbsSyncManagerDidFetch(arbs: [Arb], profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?)
    func arbsSyncManagerDidReceive(arb: Arb)
    func arbsSyncManagerDidReceiveUpdates(for arb: Arb)
    func arbsSyncManagerDidChangeSyncDate(_ newDate: Date?)
}

extension ArbsSyncManagerObserver {
    func arbsSyncManagerDidChangeLoadingState(_ isLoading: Bool) {}
    func arbsSyncManagerDidFetch(arbs: [Arb], profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?) {}
    func arbsSyncManagerDidReceive(arb: Arb) {}
    func arbsSyncManagerDidReceiveUpdates(for arb: Arb) {}
    func arbsSyncManagerDidChangeSyncDate(_ newDate: Date?) {}
}

extension ArbsSyncManager {
    static let ArbsSyncManagerStatesKey: String = "ArbsSyncManagerStatesKey"
}

extension ArbsSyncManagerObserver {

    func observeArbsSyncManagerStates() {
        let observers = ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey] ?? .init()
        observers.insert(self)
        ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey] = observers
    }

    func stopObservingAllArbsSyncManagerStates() {
        guard let observers = ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey] else { return }
        observers.remove(self)
        ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey] = observers
    }
}

extension ArbsSyncManager {

    /// Socket event observers.
    fileprivate static var observers: [String: WeakSet<ArbsSyncManagerObserver>] = [:]

    func notifyObserversAboutDidChangeLoadingState(_ isLoading: Bool, queue: OperationQueue = .main) {
        guard let observers = ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.arbsSyncManagerDidChangeLoadingState(isLoading) } }
    }

    func notifyObserversAboutDidFetch(arbs: [Arb], profiles: [ArbProfileCategory], selectedProfile: ArbProfileCategory?, queue: OperationQueue = .main) {
        guard let observers = ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.arbsSyncManagerDidFetch(arbs: arbs, profiles: profiles, selectedProfile: selectedProfile) } }
    }

    func notifyObserversAboutDidReceive(arb: Arb, queue: OperationQueue = .main) {
        guard let observers = ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.arbsSyncManagerDidReceive(arb: arb) } }
    }

    func notifyObserversAboutDidReceiveUpdates(for arb: Arb, queue: OperationQueue = .main) {
        guard let observers = ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.arbsSyncManagerDidReceiveUpdates(for: arb) } }
    }

    func notifyObserversAboutDidChangeSyncDate(_ newDate: Date?, queue: OperationQueue = .main) {
        guard let observers = ArbsSyncManager.observers[ArbsSyncManager.ArbsSyncManagerStatesKey]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.arbsSyncManagerDidChangeSyncDate(newDate) } }
    }
}
