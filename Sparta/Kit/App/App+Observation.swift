//
//  App+Observation.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.12.2020.
//

import Foundation
import SwiftyJSON
import NetworkingModels
import Networking

/// Custom mechanism to observe socket events.
/// Created as an alternative to `NotificationCenter` to have more clear and swifty syntax
/// of adding observers with no need to parse object that raises an event.

/// Represents the object that can listen to folder actions.
protocol AppObserver: class {
    func appSocketsDidChangeState(for server: SocketAPI.Server, state: SocketAPI.State)
}

extension App {

    enum ObserverKey: String {
        case socketsState
    }
}

extension AppObserver {

    func observeApp(for observerKeys: App.ObserverKey...) {

        for key in observerKeys {
            let observers = App.observers[key] ?? .init()
            observers.insert(self)
            App.observers[key] = observers
        }
    }

    func stopObservingApp(for observerKeys: App.ObserverKey...) {

        for key in observerKeys {
            guard let observers = App.observers[key] else { continue }
            observers.remove(self)
            App.observers[key] = observers
        }
    }

    func stopObservingAllAppKeys() {

        for key in App.observers.keys {
            guard let observers = App.observers[key] else { continue }
            observers.remove(self)
            App.observers[key] = observers
        }
    }
}

extension App {

    /// Sockets event observers.
    fileprivate static var observers: [ObserverKey: WeakSet<AppObserver>] = [:]

    func notifyObserversAboutChangedSocketsState(for server: SocketAPI.Server, state: SocketAPI.State, queue: OperationQueue = .main) {

        guard let observers = App.observers[.socketsState]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.appSocketsDidChangeState(for: server, state: state) } }
    }
}
