//
//  ArbFreight.swift
//  
//
//  Created by Yaroslav Babalich on 26.07.2021.
//

import Foundation
import SwiftyJSON

public struct ArbFreight: BackendModel {

    //
    // MARK: - Public properties

    public let vessel: Vessel
    public let sailingSpeed: Double
    public let sailingDays: Double
    public let sailingDistance: Double
    public let loadDays: Double
    public let canalDays: Double
    public let canalName: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        vessel = Vessel(json: json["vessel"])
        sailingSpeed = json["sailingSpeed"].doubleValue
        sailingDays = json["sailingDays"].doubleValue
        sailingDistance = json["sailingDistance"].doubleValue
        loadDays = json["loadDays"].doubleValue
        canalDays = json["canalDays"].doubleValue
        canalName = json["canalName"].stringValue
    }
}
