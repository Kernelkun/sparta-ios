//
//  ArbPlaygroundMonth.swift
//  
//
//  Created by Yaroslav Babalich on 26.07.2021.
//

import Foundation
import SwiftyJSON

public struct ArbPlaygroundMonth: BackendModel {

    //
    // MARK: - Public properties

    public let monthName: String
    public let defaultSpreadMonthName: String
    public let arrivalMonthName: String
    public var blendCost: ArbPlaygroundUnit
    public var naphtha: ArbPlaygroundNaphtha
    public var taArb: ArbPlaygroundUnit
    public var ew: ArbPlaygroundUnit
    public var freight: ArbPlaygroundUnit
    public var costs: ArbPlaygroundUnit
    public let cpBasis: ArbPlaygroundUnit
    public let loadedQuantity: ArbPlaygroundUnit
    public let flatRate: ArbPlaygroundUnit
    public let overage: ArbPlaygroundUnit
    public let salesPrice: ArbPlaygroundUnit
    public var userTarget: ArbPlaygroundUnit

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        monthName = json["monthName"].stringValue
        defaultSpreadMonthName = json["defaultSpreadMonthName"].stringValue
        arrivalMonthName = json["arrivalMonthName"].stringValue
        blendCost = ArbPlaygroundUnit(json: json["blendCost"])
        naphtha = ArbPlaygroundNaphtha(json: json["naphtha"])
        taArb = ArbPlaygroundUnit(json: json["taArb"])
        ew = ArbPlaygroundUnit(json: json["ew"])
        freight = ArbPlaygroundUnit(json: json["freight"])
        costs = ArbPlaygroundUnit(json: json["costs"])
        cpBasis = ArbPlaygroundUnit(json: json["cpBasis"])
        loadedQuantity = ArbPlaygroundUnit(json: json["loadedQuantity"])
        flatRate = ArbPlaygroundUnit(json: json["flatRate"])
        overage = ArbPlaygroundUnit(json: json["overage"])
        salesPrice = ArbPlaygroundUnit(json: json["salesPrice"])
        userTarget = ArbPlaygroundUnit(json: json["userTarget"])
    }
}

extension ArbPlaygroundMonth: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.monthName == rhs.monthName
    }
}
