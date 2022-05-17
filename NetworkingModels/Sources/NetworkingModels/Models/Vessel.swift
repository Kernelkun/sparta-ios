//
//  Vessel.swift
//  
//
//  Created by Yaroslav Babalich on 08.01.2021.
//

import Foundation
import SwiftyJSON

public struct Vessel: BackendModel, Hashable {

    //
    // MARK: - Public properties

    public let type: String
    public let speed: Double
    public let laytime: Double
    public let demurrage: Double
    public let loadStages: Double
    public let loadedQuantity: Double
    public let cpBasis: Double
    public let distance: Double
    public let comments: String
    public let marketCondition: String
    public let overage: Double
    public let basis: String
    public let rate: String
    public let routeType: String
    public let routeTypeValue: Double
    public let flatRate: Double
    public let journeyTime: JourneyTime
    public let canalDays: Int

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        type = json["type"].stringValue
        speed = json["speed"].doubleValue
        laytime = json["laytime"].doubleValue
        demurrage = json["demurrage"].doubleValue
        loadStages = json["loadStages"].doubleValue
        loadedQuantity = json["loadedQuantity"].doubleValue
        cpBasis = json["cpBasis"].doubleValue
        distance = json["distance"].doubleValue
        comments = json["comments"].stringValue
        marketCondition = json["marketCondition"].stringValue
        overage = json["overage"].doubleValue
        basis = json["basis"].stringValue
        rate = json["rate"].stringValue
        routeType = json["routeType"].stringValue
        routeTypeValue = json["routeTypeValue"].doubleValue
        flatRate = json["flatRate"].doubleValue
        journeyTime = JourneyTime(json: json["journeyTime"])
        canalDays = json["canalDays"].intValue
    }
}

public extension Vessel {

    var priorityIndex: Int {
        switch type.lowercased() {
        case "handy":
            return 1

        case "mr":
            return 2

        case "lr1":
            return 3

        case "lr2":
            return 4

        default:
            return type.lowercased().hash
        }
    }
}
