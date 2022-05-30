//
//  LiveChartSocket.swift
//  
//
//  Created by Yaroslav Babalich on 17.02.2022.
//

import Foundation
import SwiftyJSON

public struct LiveChartSocket: BackendModel {

    public enum SocketType: String {
        case heartbeat
        case aggregated = "aggregated"

        public init(rawValue: String) {
            switch rawValue.lowercased() {
            case SocketType.aggregated.rawValue:
                self = .aggregated

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

extension LiveChartSocket: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.socketType == rhs.socketType
    }
}

