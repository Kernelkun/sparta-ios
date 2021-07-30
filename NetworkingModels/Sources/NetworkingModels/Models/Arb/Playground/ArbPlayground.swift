//
//  ArbPlayground.swift
//  
//
//  Created by Yaroslav Babalich on 23.07.2021.
//

import Foundation
import SwiftyJSON

public struct ArbPlayground: BackendModel {

    //
    // MARK: - Public properties

    public let gradeCode: String
    public let routeCode: String
    public let vesselType: String
    public let pseudoRefineryFobValue: Int
    public let pseudoRefineryCifValue: Int
    public let deliveredPriceSpreads: [ArbPlaygroundDPS]
    public let months: [ArbPlaygroundMonth]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        gradeCode = json["gradeCode"].stringValue
        routeCode = json["routeCode"].stringValue
        vesselType = json["vesselType"].stringValue
        pseudoRefineryFobValue = json["pseudoRefineryFobValue"].intValue
        pseudoRefineryCifValue = json["pseudoRefineryCifValue"].intValue
        deliveredPriceSpreads = json["deliveredPriceSpreads"].arrayValue.compactMap { ArbPlaygroundDPS(json: $0) }
        months = json["months"].arrayValue.compactMap { ArbPlaygroundMonth(json: $0) }
    }
}
