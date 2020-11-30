//
//  SocketAPI.swift
//  
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import Foundation
import Starscream
import SwiftyJSON
import Reachability

public protocol SocketAPIDelegate: class {
    func socketConnectionEstablished()
    func socketConnectionLost()
}

/// Socket API Manager.
public class SocketAPI: NSObject {

    public enum State: Int, Comparable {

        case unknown = 0 // initial state
        case disconnected // connection is not established
        case connecting // connecting was started, but not yet finished
        case connected // connection is established, but authentication is not confirmed
        case authenticating // authentication was started, but not yet finished
        case authenticated // connection is established AND authentication is confirmed

        public static func < (left: State, right: State) -> Bool { left.rawValue < right.rawValue }
        public static func <= (left: State, right: State) -> Bool { left.rawValue <= right.rawValue }

        public static func > (left: State, right: State) -> Bool { left.rawValue > right.rawValue }
        public static func >= (left: State, right: State) -> Bool { left.rawValue >= right.rawValue }
    }

    //

    // swiftlint:disable:next force_unwrapping
    private static let baseURL = URL(string: "wss://core.cryptysecure.com/ws/cryptytalk/")!

    private var socket: WebSocket
    private var reachability: Reachability

    //
    // MARK: - Reconnection Handling

    private var wasForceDisconnectedLastTime: Bool = false
    private var reconnectionTimer: Timer?

    private func invalidateReconnectionTimer() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
    }

    //
    // MARK: - Requests Queue management

    private var fifoQueueWOAuth: [JSON] = []
    private var fifoQueueWithAuth: [JSON] = []
    private var ongoingQueue: [JSON] = []

    private func cleanupFIFOQueueWOAuth() {
        print("*Websocket: Starts executing queue without auth: \(fifoQueueWOAuth.count) elements*")
        fifoQueueWOAuth.forEach { sendData(data: $0, requiresAuth: false) }
        fifoQueueWOAuth.removeAll()
    }

    private func cleanupFIFOQueueWithAuth() {
        print("*Websocket: Starts executing queue with auth: \(fifoQueueWithAuth.count) elements*")
        fifoQueueWithAuth.forEach { sendData(data: $0, requiresAuth: true) }
        fifoQueueWithAuth.removeAll()
    }

    //
    // MARK: - Object Initialization

    override public init() {

        reachability = try! Reachability() // swiftlint:disable:this force_try
        try! reachability.startNotifier() // swiftlint:disable:this force_try

        //

        socket = WebSocket(url: SocketAPI.baseURL)
        state = .unknown

        super.init()

        reachability.whenReachable = { _ in self.connect() }
        reachability.whenUnreachable = { _ in self.disconnect(forced: true) }
    }

    //
    // MARK: - Public Accessors

    public weak var connectionDelegate: SocketAPIDelegate?
    public private(set) var state: State

    public func connect(tryToReconnectIfFailed: Bool = true) {

        guard state < .connected else { return }

        // If needs to reconnect, we need to setup the timer.
        if tryToReconnectIfFailed && reconnectionTimer == nil {

            reconnectionTimer = Timer.scheduledTimer(
                withTimeInterval: 1,
                repeats: true,
                block: { [weak self] _ in self?.connect() }
            )

        // Otherwise, kill the timer.
        } else if tryToReconnectIfFailed == false {
            invalidateReconnectionTimer()
        }

        //

        print("***Websocket is trying to establish connection...***")

        state = .connecting

        socket.delegate = self
        socket.connect()
    }

    public func disconnect(forced: Bool = false) {
        wasForceDisconnectedLastTime = forced
        socket.disconnect(forceTimeout: forced ? -1 : nil)
    }

    public func sendEvent(_ event: Event, requiresAuth: Bool = true, data: [String: Any?] = [:]) {

        var completedData = data
        completedData["cmd"] = event.rawValue

        sendData(data: JSON(completedData), requiresAuth: requiresAuth)
    }

    private func sendData(data: JSON, requiresAuth: Bool) {

        print("*Websocket: Current state: \(state)*")

        if requiresAuth && state < .authenticated {
            print("*Websocket: Postponed sending \(data["cmd"].stringValue): not authenticated*")
            fifoQueueWithAuth.append(data)
            return
        }

        if !requiresAuth && state < .connected {
            print("*Websocket: Postponed sending \(data["cmd"].stringValue): not connected*")
            fifoQueueWOAuth.append(data)
            return
        }

        guard ongoingQueue.contains(data) == false else {
            print("*Websocket: Aborted sending \(data["cmd"].stringValue): already in queue*")
            return
        }

        guard let rawString = data.rawString() else { return }

        // Don't add those events that actually can be duplicated.
        guard let event = Event(rawValue: data["cmd"].stringValue) else { return }

        /*if event != .getUser, event != .login,
            event != .searchUsers, event != .searchContacts,
            event != .callsList, event != .missedCallsList,
            event != .masterRejectCall {

            ongoingQueue.append(data)
        }*/

        print("*Websocket: Sending event: \(event.rawValue)*")
        //        print("*Websocket: Sending payload: \(data)*")
        socket.write(string: rawString)
    }
}

extension SocketAPI: WebSocketDelegate {

    public func websocketDidConnect(socket: WebSocketClient) {
        print("***Websocket is connected!***")
        state = .connected
        connectionDelegate?.socketConnectionEstablished()

        wasForceDisconnectedLastTime = false
        invalidateReconnectionTimer()

        cleanupFIFOQueueWOAuth()
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("***Websocket is disconnected!***")
        state = .disconnected
        connectionDelegate?.socketConnectionLost()

        ongoingQueue.removeAll()

        if !wasForceDisconnectedLastTime {
            connect()
        }
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {

        let response = JSON(parseJSON: text)
        let eventString = response["event"].stringValue
        let content = response["content"]

        print("*Websocket: Did receive event string: \(eventString)*")

        guard let event = Event(rawValue: eventString) else { return }

        print("*Websocket: Parsed to event: \(event)*")
//        print("*Websocket: Content: \(content)*")

        //
        // Remove the payload from the ongoingQueue

        let index = ongoingQueue.firstIndex { $0["cmd"].stringValue == event.rawValue }
        if let indexToDelete = index { ongoingQueue.remove(at: indexToDelete) }

        //
        // Or clearing the queue in case of an error

        /*if event == .error {
            ongoingQueue.removeAll(keepingCapacity: true)
        } else if event == .newRoomExists {
            ongoingQueue.removeAll { $0["cmd"].stringValue == Event.newRoomSinglePrivate.rawValue }
        }*/

        //
        // Notify observers about happened event

        notifyObservers(about: event, with: content)
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("*Websocket: Did receive some data: \(data)*")
    }
}

public extension SocketAPI {

    func justStartedLoggingIn() {
        guard state == .connected else { return }
        state = .authenticating
    }

    func justLoggedIn() {
        state = .authenticated
        cleanupFIFOQueueWithAuth()
    }

    func justLoggedOut() {
        state = .connected
    }
}

