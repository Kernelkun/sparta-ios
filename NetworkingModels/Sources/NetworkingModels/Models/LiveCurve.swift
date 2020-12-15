//
//  LiveCurve.swift
//  
//
//  Created by Yaroslav Babalich on 14.12.2020.
//

import Foundation
import SwiftyJSON

public struct LiveCurve: BackendModel {

    //
    // MARK: - Public properties

    public let date: String
    public let monthCode: String
    public let monthDisplay: String
    public let priceCode: String
    public let priceValue: Double
    public let inputs: [String: Any]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        let responseArray = json.stringValue.components(separatedBy: ",")

        inputs = [:]

        if responseArray.count > 0 {
            date = responseArray[0] as String
        } else {
            date = ""
        }

        if responseArray.count > 1 {
            monthCode = responseArray[1] as String
        } else {
            monthCode = ""
        }

        if responseArray.count >= 2 {
            monthDisplay = responseArray[2] as String
        } else {
            monthDisplay = ""
        }

        if responseArray.count >= 3 {
            priceCode = responseArray[3] as String
        } else {
            priceCode = ""
        }

        if responseArray.count >= 4 {
            priceValue = Double(responseArray[4]) ?? 0.0
        } else {
            priceValue = 0.0
        }
    }
}

extension LiveCurve: Equatable {

    public static func ==(lhs: LiveCurve, rhs: LiveCurve) -> Bool {
        lhs.priceCode.lowercased() == rhs.priceCode.lowercased()
    }
}
