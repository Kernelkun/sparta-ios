//
//  LCDatesSelectorViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.02.2022.
//

import Foundation
import NetworkingModels

extension LCDatesSelectorViewModel {

    struct Group {
        let name: String
        let dateSelectors: [LiveChartDateSelector]
    }
}

//  UI
extension LCDatesSelectorViewModel.Group {

    var preferredRowsCount: Int {
        if isMonthsGroup && isSingleMonth {
            return 5
        }

        if isMultipleTitle {
            return 2
        }

        return 4
    }

    var isMonthsGroup: Bool { name.lowercased() == "month" }
    var isSingleMonth: Bool {
        guard let firstItem = dateSelectors.first else { return false }

        let elementsCount = firstItem.name.components(separatedBy: "/").count

        return isMonthsGroup && elementsCount == 1
    }
    var isMultipleTitle: Bool {
        guard let firstItem = dateSelectors.first else { return false }

        let elementsCount = firstItem.name.components(separatedBy: "/").count

        return elementsCount >= 3
    }
}
