//
//  LCPortfolioAddItemViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import Foundation
import NetworkingModels

extension LCPortfolioAddItemViewModel {

    struct Item {
        let id: Int
        let title: String
        var isActive: Bool

        init(item: LiveCurveProfileProduct) {
            id = item.id
            title = item.shortName
            isActive = true
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
}

extension LCPortfolioAddItemViewModel.Group: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension LCPortfolioAddItemViewModel.Item: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
