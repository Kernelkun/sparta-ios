//
//  Port.swift
//  
//
//  Created by Yaroslav Babalich on 11.12.2020.
//

import Foundation
import SwiftyJSON

public struct Port: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let name: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
    }
}

extension Port: Equatable {

    public static func ==(lhs: Port, rhs: Port) -> Bool {
        lhs.id == rhs.id
    }
}
