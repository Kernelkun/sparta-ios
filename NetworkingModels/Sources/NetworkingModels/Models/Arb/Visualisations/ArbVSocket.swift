//
//  ArbVSocket.swift
//  
//
//  Created by Yaroslav Babalich on 28.03.2022.
//

import Foundation
import SwiftyJSON

public struct ArbVSocket: BackendModel {

    public enum SocketType: String {
        case heartbeat
        case arbmonth
        case charthistorical
        case chartarbs

        public init(rawValue: String) {
            switch rawValue.lowercased() {
            case SocketType.arbmonth.rawValue.lowercased():
                self = .arbmonth

            case SocketType.charthistorical.rawValue.lowercased():
                self = .charthistorical

            case SocketType.chartarbs.rawValue.lowercased():
                self = .chartarbs

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

extension ArbVSocket: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.socketType == rhs.socketType
    }
}

