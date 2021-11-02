//
//  ArbVSelector.swift
//  
//
//  Created by Yaroslav Babalich on 29.10.2021.
//

import Foundation
import SwiftyJSON

public struct ArbVSelector: BackendModel {

    //
    // MARK: - Public properties

    public let arbIds: [Int]
    public let isDefault: Bool
    public let gradeName: String
    public let portName: String

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        arbIds = json["arbIds"].arrayValue.compactMap { $0.intValue }
        isDefault = json["default"].boolValue
        gradeName = json["gradeName"].stringValue
        portName = json["portName"].stringValue
    }
}
