//
//  SocketAPI+Observation.swift
//  
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import Foundation
import SwiftyJSON

/// Custom mechanism to observe socket events.
/// Created as an alternative to `NotificationCenter` to have more clear and swifty syntax
/// of adding observers with no need to parse object that raises an event.

/// Represents the object that can listen to folder actions.
public protocol SocketActionObserver: class {
    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON)
}

public extension SocketActionObserver {

    func observeSocket(for servers: SocketAPI.Server...) {
        observeSocket(for: servers)
    }

    func observeSocket(for servers: [SocketAPI.Server]) {

        for server in servers {
            let observers = SocketAPI.observers[server] ?? .init()
            observers.insert(self)
            SocketAPI.observers[server] = observers
        }
    }

    func stopObservingSocket(for servers: SocketAPI.Server...) {

        for server in servers {
            guard let observers = SocketAPI.observers[server] else { continue }
            observers.remove(self)
            SocketAPI.observers[server] = observers
        }
    }

    func stopObservingAllSocketServers() {

        for server in SocketAPI.Server.allCases {
            guard let observers = SocketAPI.observers[server] else { continue }
            observers.remove(self)
            SocketAPI.observers[server] = observers
        }
    }
}

//

extension SocketAPI {

    /// Socket event observers.
    fileprivate static var observers: [SocketAPI.Server: WeakSet<SocketActionObserver>] = [:]

    /// Will go through all observers object for given socket event
    /// and will call method related to this action.
    ///
    /// - Parameter server: Server which observers will be notified.
    /// - Parameter data: JSON data that came along with the event.
    /// - Parameter queue: Operation queue, where the notification will happen.
    public func notifyObservers(about server: Server, with data: JSON, queue: OperationQueue = .main) {

        guard let observers = SocketAPI.observers[server]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.socketDidReceiveResponse(for: server, data: data) } }
    }
}
