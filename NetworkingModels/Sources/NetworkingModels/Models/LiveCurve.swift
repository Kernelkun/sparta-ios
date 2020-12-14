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

    public let monthCode: String
    public let monthDisplay: String
    public let priceCode: String
    public let priceValue: Double
    public let inputs: [String: Any]

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        let responseArray = json.stringValue.components(separatedBy: ",")

        monthCode = ""
        monthDisplay = ""
        priceCode = ""
        priceValue = 0.0
        inputs = [:]

        if responseArray.count > 0 {
            monthCode = responseArray[0] as? String ?? ""
        }

        if responseArray.count >= 1 {
            monthDisplay = responseArray[1] as? String ?? ""
        }

        if responseArray.count >= 2 {
            priceCode = responseArray[2] as? String ?? ""
        }

        if responseArray.count >= 3 {
            priceValue = responseArray[3] as? Double ?? 0.0
        }
    }
}

extension LiveCurve: Equatable {

    public static func ==(lhs: LiveCurve, rhs: LiveCurve) -> Bool {
        lhs.priceCode.lowercased() == rhs.priceCode.lowercased()
    }
}
