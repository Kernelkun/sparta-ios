//
//  PhonePrefix.swift
//  
//
//  Created by Yaroslav Babalich on 11.12.2020.
//

import Foundation
import SwiftyJSON

public struct PhonePrefix: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let prefix: String
    public let name: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        prefix = json["prefix"].stringValue
        name = json["name"].stringValue
    }
}

