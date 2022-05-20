//
//  LiveChartHighlight.swift
//  
//
//  Created by Yaroslav Babalich on 15.02.2022.
//

import Foundation
import SwiftyJSON

public struct LiveChartHighlight: BackendModel {

    //
    // MARK: - Public properties

    public let field: String
    public let high: Double?
    public let low: Double?
    public let open: Double?
    public let close: Double?

    //
    // MARK: - Default Initializers

    public init(json: JSON) {
        field = json["field"].stringValue
        high = json["high"].double
        low = json["low"].double
        open = json["open"].double
        close = json["close"].double
    }
}

extension LiveChartHighlight: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.field == rhs.field
    }
}
