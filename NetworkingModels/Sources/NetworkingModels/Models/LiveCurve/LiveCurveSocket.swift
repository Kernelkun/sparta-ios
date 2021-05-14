//
//  LiveCurveSocket.swift
//  
//
//  Created by Yaroslav Babalich on 12.05.2021.
//

import Foundation
import SwiftyJSON

public struct LiveCurveSocket: BackendModel {

    public enum SocketType: String {
        case heartbeat
        case priceUpdate = "price_update"

        public init(rawValue: String) {
            switch rawValue.lowercased() {
            case SocketType.priceUpdate.rawValue:
                self = .priceUpdate

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

extension LiveCurveSocket: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.socketType == rhs.socketType
    }
}
