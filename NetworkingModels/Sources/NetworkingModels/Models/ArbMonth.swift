//
//  ArbMonth.swift
//  
//
//  Created by Yaroslav Babalich on 30.12.2020.
//

import Foundation
import SwiftyJSON

public struct ArbMonth: BackendModel {

    //
    // MARK: - Public properties

    public let name: String
    public let gradeCode: String
    public let routeCode: String
    public let isDisabled: Bool
    public let dischargePortName: String
    public let freight: Freight
    public private(set) var blenderCost: ColoredNumber
    public let seasonality: String
    public let costIncluded: String
    public let incoterms: String
    public private(set) var gasMinusNaphtha: ColoredNumber
    public let quantities: Quantities
    public private(set) var taArb: ColoredNumber?
    public private(set) var ew: ColoredNumber?
    public let lumpsum: Double
    public let freightRate: Double
    public private(set) var deliveredPrice: DeliveredPrice?
    public private(set) var genericBlenderMargin: ColoredNumber?
    public private(set) var genericBlenderMarginChangeOnDay: ColoredNumber?
    public private(set) var pseudoFobRefinery: ColoredNumber?
    public private(set) var pseudoCifRefinery: ColoredNumber?

    // use this identifier to identify this object as unique
    public var uniqueIdentifier: String {
        name + gradeCode + routeCode
    }

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        name = json["monthName"].stringValue
        gradeCode = json["gradeCode"].stringValue
        routeCode = json["routeCode"].stringValue 
        isDisabled = json["disabled"].boolValue
        dischargePortName = json["dischargePortName"].stringValue
        freight = Freight(json: json["freight"])
        blenderCost = ColoredNumber(json: json["blenderCost"])
        seasonality = json["seasonality"].stringValue
        costIncluded = json["costIncluded"].stringValue
        incoterms = json["incoterms"].stringValue
        gasMinusNaphtha = ColoredNumber(json: json["gasMinusNaphtha"])
        quantities = Quantities(json: json["quantities"])

        if json["taArb"].dictionary != nil {
            taArb = ColoredNumber(json: json["taArb"])
        } else { taArb = nil }

        lumpsum = json["lumpsum"].doubleValue
        freightRate = json["freightRate"].doubleValue

        if json["deliveredPrice"].dictionary != nil {
            deliveredPrice = DeliveredPrice(json: json["deliveredPrice"])
        } else { deliveredPrice = nil }

        if json["genericBlenderMargin"].dictionary != nil {
            genericBlenderMargin = ColoredNumber(json: json["genericBlenderMargin"])
        } else { genericBlenderMargin = nil }

        if json["ew"].dictionary != nil {
            ew = ColoredNumber(json: json["ew"])
        } else { ew = nil }

        if json["genericBlenderMarginChangeOnDay"].dictionary != nil {
            genericBlenderMarginChangeOnDay = ColoredNumber(json: json["genericBlenderMarginChangeOnDay"])
        } else { genericBlenderMarginChangeOnDay = nil }

        if json["pseudoFobRefinery"].dictionary != nil {
            pseudoFobRefinery = ColoredNumber(json: json["pseudoFobRefinery"])
        } else { pseudoFobRefinery = nil }

        if json["pseudoCifRefinery"].dictionary != nil {
            pseudoCifRefinery = ColoredNumber(json: json["pseudoCifRefinery"])
        } else {  pseudoCifRefinery = nil }
    }

    // MARK: - Public methods

    public mutating func update(from newMonth: ArbMonth) {
        blenderCost = newMonth.blenderCost
        gasMinusNaphtha = newMonth.gasMinusNaphtha
        taArb = newMonth.taArb
        deliveredPrice = newMonth.deliveredPrice
        genericBlenderMargin = newMonth.genericBlenderMargin
        genericBlenderMarginChangeOnDay = newMonth.genericBlenderMarginChangeOnDay
        pseudoFobRefinery = newMonth.pseudoFobRefinery
        pseudoCifRefinery = newMonth.pseudoCifRefinery
        ew = newMonth.ew
    }
}

extension ArbMonth: Equatable {

    public static func ==(lhs: ArbMonth, rhs: ArbMonth) -> Bool {
        lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
}

// Freight

public extension ArbMonth {

    struct Freight {

        public struct RouteType {

            //
            // MARK: - Public properties

            public let routeType: String
            public let routeValue: String

            public var displayRouteValue: String? {
                guard routeValue != "0" else { return nil }

                return routeValue
            }

            //
            // MARK: - Default Initializers

            public init(json: JSON) {
                routeType = json["routeType"].stringValue
                routeValue = json["routeValue"].stringValue
            }
        }

        //
        // MARK: - Public properties

        public let loadDate: String
        public let voyageDays: Int
        public let arrivalDate: String
        public let isDisabled: Bool
        public let dischargePortName: String
        public let routeType: RouteType
        public let freightRate: Double

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            loadDate = json["loadDate"].stringValue
            voyageDays = json["voyageDays"].intValue
            arrivalDate = json["arrivalDate"].stringValue
            isDisabled = json["disabled"].boolValue
            dischargePortName = json["dischargePortName"].stringValue
            routeType = RouteType(json: json["routeType"])
            freightRate = json["freightRate"].doubleValue
        }
    }
}

// Quantities

public extension ArbMonth {

    struct Quantities {

        //
        // MARK: - Public properties

        public let density: Double
        public let quantityRestriction: Double
        public let loadedQuantity: Double

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            density = json["density"].doubleValue
            quantityRestriction = json["quantityRestriction"].doubleValue
            loadedQuantity = json["loadedQuantity"].doubleValue
        }
    }
}

// Delivered Price

public extension ArbMonth {

    struct DeliveredPrice {

        //
        // MARK: - Public properties

        public let value: ColoredNumber
        public let units: String
        public let basis: String

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            value = ColoredNumber(json: json["value"])
            units = json["units"].stringValue
            basis = json["basis"].stringValue
        }
    }
}
