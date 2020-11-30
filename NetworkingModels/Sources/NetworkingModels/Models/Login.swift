//
//  Login.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation
import SwiftyJSON

public struct Login: BackendModel {

    //
    // MARK: - Public properties

    public var jwt: String
    public let user: User

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        jwt = json["jwt"].stringValue
        user = User(json: json["user"])
    }
}
