//
//  ArbV.swift
//  
//
//  Created by Yaroslav Babalich on 09.11.2021.
//

import Foundation
import SwiftyJSON

public struct ArbV: BackendModel {

    //
    // MARK: - Public properties

    public let arbId: Int
    public let order: Int
    public let loadRegion: String
    public let loadRegionId: Int
    public let loadRegionOrder: Int
    public let grade: String
    public let route: String
    public let vesselType: String
    public let visible: Bool
    public let relatedArbIds: [Int]
    public let units: String
    public let basis: String
    public let values: [Value]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        arbId = json["arbId"].intValue
        order = json["order"].intValue
        loadRegion = json["loadRegion"].stringValue
        loadRegionId = json["loadRegionId"].intValue
        loadRegionOrder = json["loadRegionOrder"].intValue
        grade = json["grade"].stringValue
        route = json["route"].stringValue
        vesselType = json["vesselType"].stringValue
        visible = json["visible"].boolValue
        relatedArbIds = json["relatedArbIds"].arrayValue.compactMap { $0.intValue }
        units = json["units"].stringValue
        basis = json["basis"].stringValue
        values = json["values"].arrayValue.compactMap { ArbV.Value(json: $0) }
    }
}

extension ArbV {

    // use this unique identifier for receiving data from sockets
    public func uniqueIdentifier(from value: Value) -> Identifier<String> {
        let stringIdentifier = (self.arbId.toString + value.deliveryMonth).trimmed.lowercased()
        return Identifier(id: stringIdentifier)
    }
}
