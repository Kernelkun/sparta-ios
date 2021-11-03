//
//  ArbVSocket.swift
//  
//
//  Created by Yaroslav Babalich on 02.11.2021.
//

import Foundation
import SwiftyJSON

public struct ArbVSocket: BackendModel {

    //
    // MARK: - Public properties

    public let arbId: Int
    public let loadMonth: String
    public let deliveredPrice: String
    public let margins: [ArbVMargin]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        arbId = json["arbId"].intValue
        loadMonth = json["loadMonth"].stringValue
        deliveredPrice = json["deliveredPrice"].stringValue
        margins = json["margins"].arrayValue.compactMap { ArbVMargin(json: $0) }
    }
}
