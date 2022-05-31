//
//  Environment+Visualisations.swift
//  
//
//  Created by Yaroslav Babalich on 25.03.2022.
//

import Foundation

public extension Environment {
    struct Visualisations {
        public enum DateRange: String, CaseIterable {
            case month = "by_month"
            case semidecade = "by_semidecade"
        }
    }
}
