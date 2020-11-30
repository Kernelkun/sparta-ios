//
//  File.swift
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
    func socketDidReceiveResponse(for event: SocketAPI.Event, data: JSON)
}

public extension SocketActionObserver {

    func observeSocket(for events: SocketAPI.Event...) {
        observeSocket(for: events)
    }

    func observeSocket(for events: [SocketAPI.Event]) {

        for event in events {
            let observers = SocketAPI.observers[event] ?? .init()
            observers.insert(self)
            SocketAPI.observers[event] = observers
        }
    }

    func stopObservingSocket(for events: SocketAPI.Event...) {

        for event in events {
            guard let observers = SocketAPI.observers[event] else { continue }
            observers.remove(self)
            SocketAPI.observers[event] = observers
        }
    }

    func stopObservingAllSocketEvents() {

        for event in SocketAPI.Event.allCases {
            guard let observers = SocketAPI.observers[event] else { continue }
            observers.remove(self)
            SocketAPI.observers[event] = observers
        }
    }
}

//

extension SocketAPI {

    /// Socket event observers.
    fileprivate static var observers: [SocketAPI.Event: WeakSet<SocketActionObserver>] = [:]

    /// Will go through all observers object for given socket event
    /// and will call method related to this action.
    ///
    /// - Parameter event: Event about which observers will be notified.
    /// - Parameter data: JSON data that came along with the event.
    /// - Parameter queue: Operation queue, where the notification will happen.
    public func notifyObservers(about event: Event, with data: JSON, queue: OperationQueue = .main) {

        guard let observers = SocketAPI.observers[event]?.allObjects else { return }
        queue.addOperation { observers.forEach { $0.socketDidReceiveResponse(for: event, data: data) } }
    }
}

