//
//  LiveChartDateSelector.swift
//  
//
//  Created by Yaroslav Babalich on 14.02.2022.
//

import Foundation
import SwiftyJSON

public struct LiveChartDateSelector: BackendModel {

    //
    // MARK: - Public properties

    public let name: String
    public let code: String
    public let group: String
    public let type: String
    public let isDefaut: Bool

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        name = json["name"].stringValue
        code = json["code"].stringValue
        group = json["group"].stringValue
        type = json["type"].stringValue
        isDefaut = json["isDefaut"].boolValue
    }
}

extension LiveChartDateSelector: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
}
