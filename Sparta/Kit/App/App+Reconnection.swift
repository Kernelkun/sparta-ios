//
//  App+Reconnection.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.12.2020.
//

import Foundation
import Networking
import SwiftyJSON

extension App {

    // MARK: - Public methods

    func socketsConnect(toServer: SocketAPI.Server) {
        if sockets.state >= .connected {
            if needChangeServer(to: toServer) {
                sockets.change(to: toServer)
                sockets.connect()
            }
        } else {
            sockets.change(to: toServer)
            sockets.connect()
        }
    }

    // MARK: - Private methods

    private func needChangeServer(to server: SocketAPI.Server) -> Bool {
        sockets.serverType != server
    }
}

extension App: SocketAPIDelegate {

    func socketConnectionEstablished() {
        guard let token = token else { return }
        
        sockets.sendData(data: JSON(token), requiresAuth: false)
    }

    func socketConnectionLost() {
    }
}
