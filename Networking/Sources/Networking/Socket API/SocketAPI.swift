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

public protocol SocketAPIDelegate: AnyObject {
    func socketConnectionEstablished()
    func socketConnectionLost()
    func socketConnectionDidChangeState(_ newState: SocketAPI.State)
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

    private var socket: WebSocket?

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

    public init(defaultServer: Server? = nil) {
        guard let defaultServer = defaultServer,
              let serverLink = defaultServer.link else {

            socket = nil
            serverType = .unknown
            state = .unknown

            super.init()
            return
        }

        serverType = defaultServer

        socket = WebSocket(url: serverLink)
        state = .unknown

        super.init()
    }

    //
    // MARK: - Public Accessors

    public var serverType: SocketAPI.Server
    public weak var connectionDelegate: SocketAPIDelegate?
    public private(set) var state: State {
        didSet {
            connectionDelegate?.socketConnectionDidChangeState(state)
        }
    }

    // this method will just change server without reconnection
    public func change(to server: SocketAPI.Server) {
        guard let serverLink = server.link else { return }

        if state <= .connected {
            disconnect(forced: true)
        }

        serverType = server

        socket = WebSocket(url: serverLink)
        state = .unknown
    }

    public func connect(tryToReconnectIfFailed: Bool = true) {

        guard state < .connected, socket != nil else { return }

        // If needs to reconnect, we need to setup the timer.
        if tryToReconnectIfFailed && reconnectionTimer == nil {

            reconnectionTimer = Timer.scheduledTimer(
                withTimeInterval: 10,
                repeats: true,
                block: { [weak self] _ in self?.connect() }
            )

        // Otherwise, kill the timer.
        } else if tryToReconnectIfFailed == false {
            invalidateReconnectionTimer()
        }

        //

        print("*Websocket: is trying to establish connection... \(serverType.rawValue) ***")

        state = .connecting

        socket!.delegate = self
        socket!.connect()
    }

    public func disconnect(forced: Bool = false) {
        guard socket != nil else { return }

        wasForceDisconnectedLastTime = forced
        socket!.disconnect(forceTimeout: forced ? -1 : nil)
    }

    public func sendData(data: JSON, requiresAuth: Bool) {
        guard socket != nil else { return }

        print("*Websocket: Did send data \(data.rawString()), server: \(serverType)*")

        guard let rawString = data.rawString() else { return }

        socket!.write(string: rawString)
    }
}

extension SocketAPI: WebSocketDelegate {

    public func websocketDidConnect(socket: WebSocketClient) {
        print("*Websocket: is connected! \(serverType.rawValue) ***")
        state = .connected
        connectionDelegate?.socketConnectionEstablished()

        wasForceDisconnectedLastTime = false
        invalidateReconnectionTimer()

        cleanupFIFOQueueWOAuth()
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("*Websocket: is disconnected!\(serverType.rawValue) ***")
        state = .disconnected
        connectionDelegate?.socketConnectionLost()

        ongoingQueue.removeAll()

        if !wasForceDisconnectedLastTime {
            connect()
        }
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {

        let response = JSON(parseJSON: text)

        print("*Websocket: Did receive some \(text)*")

        //
        // Notify observers about happened event

        notifyObservers(about: serverType, with: response)
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
