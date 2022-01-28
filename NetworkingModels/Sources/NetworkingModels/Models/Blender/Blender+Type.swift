//
//  Blender+Type.swift
//  
//
//  Created by Yaroslav Babalich on 12.01.2022.
//

import Foundation
import SwiftyJSON

public extension Blender {

    enum `Type`: String {
        case unknown
        case normal = "normal"
        case counterSesonality = "counter_seasonality"
        case regrade = "regrade"
        case userCustom = "user_custom"

        // MARK: - Initialziers

        public init(rawValue: String) {
            switch rawValue.lowercased() {
            case Self.normal.rawValue: self = .normal
            case Self.counterSesonality.rawValue: self = .counterSesonality
            case Self.regrade.rawValue: self = .regrade
            case Self.userCustom.rawValue: self = .userCustom

            default:
                self = .unknown
            }
        }
    }
}
