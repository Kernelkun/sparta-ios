//
//  Arb.swift
//  
//
//  Created by Yaroslav Babalich on 30.12.2020.
//

import Foundation
import SwiftyJSON

public struct Arb: BackendModel {

    //
    // MARK: - Public properties

    public let grade: String
    public let gradeCode: String
    public let routeCode: String
    public let dischargePortName: String
    public let escalation: String
    public let months: [BlenderMonth]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        grade = json["gradeName"].stringValue
        gradeCode = json["gradeCode"].stringValue
        routeCode = json["routeCode"].stringValue
        dischargePortName = json["dischargePortName"].stringValue
        escalation = json["escalation"].stringValue
        months = json["months"].arrayValue.compactMap { BlenderMonth(json: $0) }
    }
}

extension Arb: Equatable {

    public static func ==(lhs: Arb, rhs: Arb) -> Bool {
        lhs.gradeCode.lowercased() == rhs.gradeCode.lowercased()
    }
}
