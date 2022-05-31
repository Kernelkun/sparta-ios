//
//  ArbVMonthSocket.swift
//  
//
//  Created by Yaroslav Babalich on 28.03.2022.
//

import Foundation
import SwiftyJSON

public struct ArbVMonthSocket: BackendModel {

    //
    // MARK: - Public properties

    public let arbId: Int
    public let deliveryMonth: String
    public let deliveryWindow: String
    public let loadMonth: String
    public let loadWindow: String
    public let deliveredPrice: ArbV.DeliveredPrice
    public let margins: [ArbV.Margin]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        arbId = json["arbId"].intValue
        deliveryMonth = json["deliveryMonth"].stringValue
        deliveryWindow = json["deliveryWindow"].stringValue
        loadMonth = json["loadMonth"].stringValue
        loadWindow = json["loadWindow"].stringValue
        deliveredPrice = ArbV.DeliveredPrice(json: json["deliveredPrice"])
        margins = json["margins"].arrayValue.compactMap { ArbV.Margin(json: $0) }
    }
}

extension ArbVMonthSocket {

    // use this unique identifier for receiving data from sockets
    public var uniqueIdentifier: Identifier<String> {
        let stringIdentifier = (arbId.toString + deliveryMonth).trimmed.lowercased()
        return Identifier(id: stringIdentifier)
    }
}
