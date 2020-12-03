//
//  Blender.swift
//  
//
//  Created by Yaroslav Babalich on 03.12.2020.
//

import Foundation
import SwiftyJSON

public struct Blender: BackendModel {

    //
    // MARK: - Public properties

    public let grade: String
    public let gradeCode: String
    public let basis: String
    public let naphtha: String
    public let escalation: String
    public let months: [BlenderMonth]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        grade = json["grade"].stringValue
        gradeCode = json["gradeCode"].stringValue
        basis = json["basis"].stringValue
        naphtha = json["naphtha"].stringValue
        escalation = json["escalation"].stringValue
        months = json["months"].arrayValue.compactMap { BlenderMonth(json: $0) }
    }
}

extension Blender: Equatable {

    public static func ==(lhs: Blender, rhs: Blender) -> Bool {
        lhs.gradeCode.lowercased() == rhs.gradeCode.lowercased()
    }
}
