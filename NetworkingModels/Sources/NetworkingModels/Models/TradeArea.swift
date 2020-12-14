//
//  TradeArea.swift
//  
//
//  Created by Yaroslav Babalich on 11.12.2020.
//

import Foundation
import SwiftyJSON

public struct TradeArea: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let name: String

    public let primaryPorts: [Port]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue

        primaryPorts = json["primary_ports"].arrayValue.compactMap { Port(json: $0) }
    }
}

extension TradeArea: Equatable {

    public static func ==(lhs: TradeArea, rhs: TradeArea) -> Bool {
        lhs.id == rhs.id
    }
}
