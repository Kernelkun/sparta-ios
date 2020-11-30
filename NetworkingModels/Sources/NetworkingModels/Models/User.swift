//
//  User.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation
import SwiftyJSON

public struct User: BackendModel {

    //
    // MARK: - Public properties

    public var id: Int
    public var username: String?
    public var email: String
    public var isConfirmed: Bool
    public var isBlocked: Bool

    //
    // MARK: - Default Initializers

    public init(json: JSON) {

        id = json["id"].intValue

        username = json["username"].string
        email = json["email"].stringValue
        isConfirmed = json["confirmed"].boolValue
        isBlocked = json["blocked"].boolValue
    }
}
