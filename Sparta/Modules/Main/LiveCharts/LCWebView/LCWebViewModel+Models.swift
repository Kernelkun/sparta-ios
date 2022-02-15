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
        let id: Int
        let title: String
        let code: String

        init(item: LiveCurveProfileProduct) {
            id = item.id
            title = item.shortName + " " + "(" + item.unit + ")"
            code = item.code
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

    struct DateSelector {
        let name: String

        init(dateSelector: LiveChartDateSelector) {
            self.name = dateSelector.name
        }
    }

    struct Configurator {
        let item: Item
        var dateSelector: DateSelector?
        var dateSelectors: [LiveChartDateSelector] = []

        var selectedDateSelector: LiveChartDateSelector? {
            guard !dateSelectors.isEmpty else { return nil }

            if let dateSelector = dateSelector,
               let dateSelectorIndex = dateSelectors.firstIndex(where: { dateSelector.name.lowercased() == $0.name.lowercased() }) {

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

extension LCWebViewModel.Item: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
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
