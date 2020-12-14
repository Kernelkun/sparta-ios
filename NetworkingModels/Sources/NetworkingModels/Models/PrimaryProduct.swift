//
//  PrimaryProduct.swift
//  
//
//  Created by Yaroslav Babalich on 11.12.2020.
//

import Foundation
import SwiftyJSON

public struct PrimaryProduct: BackendModel {

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

extension PrimaryProduct: Equatable {

    public static func ==(lhs: PrimaryProduct, rhs: PrimaryProduct) -> Bool {
        lhs.id == rhs.id
    }
}
