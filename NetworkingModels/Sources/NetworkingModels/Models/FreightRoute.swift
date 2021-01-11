//
//  FreightRoute.swift
//  
//
//  Created by Yaroslav Babalich on 08.01.2021.
//

import Foundation
import SwiftyJSON

public struct FreightRoute: BackendModel {

    //
    // MARK: - Public properties

    public let loadPort: FreightPort
    public let dischargePort: DischargePort
    public let vessels: [Vessel]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        loadPort = FreightPort(json: json["loadPort"])
        dischargePort = DischargePort(json: json["dischargePort"])
        vessels = json["vessels"].arrayValue.compactMap { Vessel(json: $0) }
    }
}
