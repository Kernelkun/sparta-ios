//
//  BlenderMonthComponent.swift
//  
//
//  Created by Yaroslav Babalich on 03.12.2020.
//

import Foundation
import SwiftyJSON

public struct BlenderMonthComponent: BackendModel {

    //
    // MARK: - Public properties

    public let rawValue: Int
    public let density: Double
    public let value: String
    public let name: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        rawValue = json["rawValue"].intValue
        density = json["density"].doubleValue
        value = json["value"].stringValue
        name = json["name"].stringValue
    }
}
