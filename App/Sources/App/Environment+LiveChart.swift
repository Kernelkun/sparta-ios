//
//  Environment+LiveChart.swift
//  
//
//  Created by Yaroslav Babalich on 25.03.2022.
//

import Foundation

public extension Environment {
    struct LiveChart {
        public enum Resolution: String, CaseIterable {
            case minute1 = "1m"
            case hour1 = "1h"
            case day1 = "1d"
            case week1 = "1w"
            case month1 = "1M"
            case week52 = "52w"
        }
    }
}
