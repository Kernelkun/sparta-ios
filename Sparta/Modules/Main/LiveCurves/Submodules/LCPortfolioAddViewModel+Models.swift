//
//  LCPortfolioAddViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import Foundation
import NetworkingModels

extension LCPortfolioAddViewModel {

    struct LiveCurveItem {
        let title: String
        var isActive: Bool

        fileprivate init(liveCurve: LiveCurveProfileItem) {
            title = liveCurve.shortName
            isActive = true
        }
    }

    struct Category {
        let title: String
        let items: [LiveCurveItem]

        init(category: LiveCurveProfileCategory) {
            title = category.name
            items = category.liveCurves.compactMap { LiveCurveItem(liveCurve: $0) }
        }
    }
}
