//
//  ArbVMargin.swift
//  
//
//  Created by Yaroslav Babalich on 02.11.2021.
//

import Foundation
import SwiftyJSON

public struct ArbVMargin: BackendModel {

    //
    // MARK: - Public properties

    public let type: String
    public let displayedValue: String
    public let price: ColoredNumber

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        type = json["type"].stringValue
        displayedValue = json["displayedValue"].stringValue
        price = ColoredNumber(json: json)
    }
}
