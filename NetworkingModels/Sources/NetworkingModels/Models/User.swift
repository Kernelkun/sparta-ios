//
//  User.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation
import SwiftyJSON

public struct User: BackendModel {

    //
    // MARK: - Public properties

    public var id: Int
    public var email: String

    public var username: String?
    public var firstName: String?
    public var lastName: String?

    public var isConfirmed: Bool
    public var isBlocked: Bool

    public var mobileNumber: String?
    public var mobilePrefixIndex: Int?

    public var primaryPort: Int?
    public var primaryProduct: Int?
    public var primaryTradeRegion: Int?
    public var role: Int?

    // HOU months

    public var houBlenderMonths: Int
    public var houArbMonths: Int

    // navigation sections

    public let freight: Bool
    public let blender: Bool
    public let arbs: Bool
    public let liveprices: Bool
    public let liveCharts: Bool

    //
    // MARK: - Default Initializers

    public init(json: JSON) {

        id = json["id"].intValue
        email = json["email"].stringValue

        username = json["username"].string
        firstName = json["name"].string
        lastName = json["lastname"].string

        isConfirmed = json["confirmed"].boolValue
        isBlocked = json["blocked"].boolValue

        mobileNumber = json["mobile_number"].string
        mobilePrefixIndex = json["mobile_prefix"].int

        primaryPort = json["primary_port"].int
        primaryProduct = json["primary_product"].int
        primaryTradeRegion = json["primary_trade_region"].int
        role = json["user_role"].int

        freight = json["freight"].boolValue
        blender = json["blender"].boolValue
        arbs = json["arbs"].boolValue
        liveprices = json["liveprices"].boolValue
        liveCharts = json["liveCharts"].boolValue

        houBlenderMonths = json["houston_blender_months"].intValue
        houArbMonths = json["houston_arbs_months"].intValue
    }
}
