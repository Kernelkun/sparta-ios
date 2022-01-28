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
    public let referenceCode: String
    public let basis: String
    public let naphtha: String
    public let escalation: String
    public var months: [BlenderMonth]
    public let loadRegion: BlenderRegion
    public let priceInfo: [PriceInfo]
    public let portfolioConfiguration: PortfolioConfiguration
    public let portfolio: Portfolio
    public let type: `Type`

    // for presenting

    public var isCustom: Bool
    public var priorityIndex: Int = -1

    // use this identifier to identify this object as unique on the backside
    public var serverUniqueIdentifier: String { gradeCode }

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        grade = json["grade"].stringValue
        gradeCode = json["gradeCode"].stringValue
        basis = json["basis"].stringValue
        naphtha = json["naphtha"].stringValue
        escalation = json["escalation"].stringValue
        months = json["months"].arrayValue.compactMap { BlenderMonth(json: $0) }
        isCustom = json["isCustom"].boolValue
        loadRegion = BlenderRegion(json: json["loadRegion"])
        priceInfo = json["priceInfo"].arrayValue.compactMap { PriceInfo(json: $0) }
        portfolioConfiguration = PortfolioConfiguration(json: json)
        portfolio = Portfolio(json: json)

        referenceCode = json["referenceCode"].stringValue
        type = Type(rawValue: json["type"].stringValue)
    }
}

extension Blender: Equatable {

    public static func ==(lhs: Blender, rhs: Blender) -> Bool {
        lhs.gradeCode.lowercased() == rhs.gradeCode.lowercased()
    }
}
