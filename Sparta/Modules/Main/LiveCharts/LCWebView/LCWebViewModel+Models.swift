//
//  LCWebViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.02.2022.
//

import Foundation
import NetworkingModels

extension LCWebViewModel {

    struct Item {
        let title: String
        let code: String

        init(item: LiveCurveProfileProduct) {
            title = item.shortName //+ " " + "(" + item.unit + ")"
            code = item.code
        }

        init(monthInfo: LiveCurveMonthInfoModel) {
            title = monthInfo.lcName //+ " " + "(" + monthInfo.lcUnit + ")"
            code = monthInfo.lcCode
        }
    }

    struct Group {
        let id: Int
        let title: String
        var items: [Item]

        init(group: LiveCurveProfileGroup) {
            id = group.id
            title = group.name
            items = []
        }
    }

    struct Highlight {
        let type: HighlightType
        let value: String
    }

    struct DateSelector {
        let name: String
        let code: String

        init(dateSelector: LiveChartDateSelector) {
            self.name = dateSelector.name
            self.code = dateSelector.code
        }

        init(name: String, code: String) {
            self.name = name
            self.code = code
        }
    }

    struct Configurator {
        let item: Item
        var dateSelector: DateSelector?
        var dateSelectors: [LiveChartDateSelector] = []
        var highlights: [Highlight] = []

        var selectedDateSelector: LiveChartDateSelector? {
            guard !dateSelectors.isEmpty else { return nil }

            if let dateSelector = dateSelector,
               let dateSelectorIndex = dateSelectors.firstIndex(where: { dateSelector.code.lowercased() == $0.code.lowercased() }) {

                return dateSelectors[dateSelectorIndex]
            } else {
                return dateSelectors.first(where: { $0.isDefaut })
            }
        }

        init(item: Item) {
            self.item = item
            self.dateSelector = nil
            self.dateSelectors = []
        }
    }
}

extension LCWebViewModel.Group: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension LCWebViewModel.Highlight {
    enum HighlightType: String, CaseIterable {
        case open = "Open"
        case previousClose = "Previous Close"
        case week52Low = "52 Week Low"
        case week52High = "52 Week High"
        case monthLow = "Month Low"
        case monthHigh = "Month High"
    }
}

extension Array where Element == LCWebViewModel.Group {

    func filtered(by searchRequest: String?) -> [Element] {
        guard let searchRequest = searchRequest else { return self }

        return compactMap { group -> Element in
            var group = group
            group.items = group.items.filter { $0.title.lowercased().contains(searchRequest.lowercased()) }
            return group
        }
    }
}
