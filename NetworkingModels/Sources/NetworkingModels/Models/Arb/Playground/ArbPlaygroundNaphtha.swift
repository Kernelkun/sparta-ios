//
//  ArbPlaygroundNaphtha.swift
//  
//
//  Created by Yaroslav Babalich on 26.07.2021.
//

import Foundation
import SwiftyJSON

public struct ArbPlaygroundNaphtha: BackendModel {

    //
    // MARK: - Public properties

    public let value: Double
    public let pricingComponentsVolume: Double

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        value = json["value"].doubleValue
        pricingComponentsVolume = json["pricingComponentsVolume"].doubleValue
    }
}
