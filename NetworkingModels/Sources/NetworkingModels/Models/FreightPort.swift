//
//  FreightPort.swift
//  
//
//  Created by Yaroslav Babalich on 08.01.2021.
//

import Foundation
import SwiftyJSON

public struct FreightPort: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let name: String
    public let code: String
    public let dischargePorts: [DischargePort]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        code = json["code"].stringValue
        dischargePorts = json["dischargePorts"].arrayValue.compactMap { DischargePort(json: $0) }
    }
}

extension FreightPort: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
