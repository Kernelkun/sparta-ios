//
//  Favourite.swift
//  
//
//  Created by Yaroslav Babalich on 17.02.2021.
//

import Foundation
import SwiftyJSON

public struct Favourite: BackendModel {

    //
    // MARK: - Public properties

    public let id: Int
    public let code: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        code = json["code"].stringValue
    }

    public init(id: Int, code: String) {
        self.id = id
        self.code = code
    }
}

extension Favourite: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
}
