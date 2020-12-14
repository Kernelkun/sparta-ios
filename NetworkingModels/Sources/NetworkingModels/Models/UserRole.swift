//
//  UserRole.swift
//  
//
//  Created by Yaroslav Babalich on 11.12.2020.
//

import Foundation
import SwiftyJSON

public struct UserRole: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let name: String

    public let primaryProducts: [PrimaryProduct]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue

        primaryProducts = json["primary_products"].arrayValue.compactMap { PrimaryProduct(json: $0) }
    }
}

extension UserRole: Equatable {

    public static func ==(lhs: UserRole, rhs: UserRole) -> Bool {
        lhs.id == rhs.id
    }
}
