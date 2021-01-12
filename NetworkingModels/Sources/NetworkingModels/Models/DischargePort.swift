//
//  DischargePort.swift
//  
//
//  Created by Yaroslav Babalich on 08.01.2021.
//

import Foundation
import SwiftyJSON

public struct DischargePort: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let name: String
    public let code: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        code = json["code"].stringValue
    }
}
