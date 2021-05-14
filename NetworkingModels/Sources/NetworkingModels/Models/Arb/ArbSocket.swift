//
//  ArbSocket.swift
//  
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import Foundation
import SwiftyJSON

public struct ArbSocket: BackendModel {

    public enum SocketType: String {
        case heartbeat
        case arbMonth

        public init(rawValue: String) {
            switch rawValue.lowercased() {
            case SocketType.arbMonth.rawValue.lowercased():
                self = .arbMonth

            default:
                self = .heartbeat
            }
        }
    }

    //
    // MARK: - Public properties

    public let payload: JSON
    public let socketType: SocketType

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        payload = json["payload"]
        socketType = SocketType(rawValue: json["type"].stringValue)
    }
}

extension ArbSocket: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.socketType == rhs.socketType
    }
}
