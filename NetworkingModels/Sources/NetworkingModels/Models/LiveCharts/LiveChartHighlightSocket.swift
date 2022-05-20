//
//  LiveChartHighlightSocket.swift
//  
//
//  Created by Yaroslav Babalich on 17.02.2022.
//

import Foundation
import SwiftyJSON

public struct LiveChartHighlightSocket: BackendModel {

    //
    // MARK: - Public properties

    public let spartaCode: String
    public let tenorName: String
    public let resolution: String
    public let open: Double?
    public let close: Double?
    public let high: Double?
    public let low: Double?

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        spartaCode = json["sc"].stringValue
        tenorName = json["tn"].stringValue
        resolution = json["r"].stringValue
        high = json["h"].double
        low = json["l"].double
        open = json["o"].double
        close = json["c"].double
    }
}

extension LiveChartHighlightSocket: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.spartaCode == rhs.spartaCode
            && lhs.tenorName == rhs.tenorName
    }
}

