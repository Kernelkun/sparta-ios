//
//  BlenderRegion.swift
//  
//
//  Created by Yaroslav Babalich on 05.07.2021.
//

import Foundation
import SwiftyJSON

public struct BlenderRegion: BackendModel {

    //
    // MARK: - Public properties

    public var id: Int
    public var name: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
    }
}

extension BlenderRegion: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }
}
