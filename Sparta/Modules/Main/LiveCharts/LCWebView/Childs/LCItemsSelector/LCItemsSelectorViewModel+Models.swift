//
//  LCItemsSelectorViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import Foundation
import NetworkingModels

extension LCItemsSelectorViewModel {

    struct Item {
        let id: Int
        let title: String

        init(item: LiveCurveProfileProduct) {
            id = item.id
            title = item.shortName + " " + "(" + item.unit + ")"
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

extension LCItemsSelectorViewModel.Group: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension LCItemsSelectorViewModel.Item: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Array where Element == LCItemsSelectorViewModel.Group {

    func filtered(by searchRequest: String?) -> [Element] {
        guard let searchRequest = searchRequest else { return self }

        return compactMap { group -> Element in
            var group = group
            group.items = group.items.filter { $0.title.lowercased().contains(searchRequest.lowercased()) }
            return group
        }
    }
}

