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
    public let blenderCost: ColoredNumber
    public let seasonality: String
    public let costIncluded: String
    public let incoterms: String
    public let gasMinusNaphtha: ColoredNumber
    public let quantities: Quantities
    public let taArb: String
    public let ew: String
    public let lumpsum: Double
    public let freightRate: Double
    public let deliveredPrice: DeliveredPrice
    public let genericBlenderMargin: ColoredNumber
    public let genericBlenderMarginChangeOnDay: ColoredNumber
    public let pseudoFobRefinery: ColoredNumber
    public let pseudoCifRefinery: String

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
        taArb = json["taArb"].stringValue
        ew = json["ew"].stringValue
        lumpsum = json["lumpsum"].doubleValue
        freightRate = json["freightRate"].doubleValue
        deliveredPrice = DeliveredPrice(json: json["deliveredPrice"])
        genericBlenderMargin = ColoredNumber(json: json["genericBlenderMargin"])
        genericBlenderMarginChangeOnDay = ColoredNumber(json: json["genericBlenderMarginChangeOnDay"])
        pseudoFobRefinery = ColoredNumber(json: json["pseudoFobRefinery"])
        pseudoCifRefinery = json["pseudoCifRefinery"].stringValue
    }
}

extension ArbMonth: Equatable {

    public static func ==(lhs: ArbMonth, rhs: ArbMonth) -> Bool {
        lhs.gradeCode.lowercased() == rhs.gradeCode.lowercased()
            && lhs.name.lowercased() == rhs.name.lowercased()
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

        //
        // MARK: - Default Initializers

        public init(json: JSON) {
            loadDate = json["loadDate"].stringValue
            voyageDays = json["voyageDays"].intValue
            arrivalDate = json["arrivalDate"].stringValue
            isDisabled = json["disabled"].boolValue
            dischargePortName = json["dischargePortName"].stringValue
            routeType = RouteType(json: json["routeType"])
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
