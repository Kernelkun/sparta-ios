//
//  LCWebSaver.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.06.2022.
//

import Foundation

class LCWebSaver {

    // MARK: - Private properties

    private var savedItems: [Item] = []

    // MARK: - Public methods

    func saveItem(_ item: Item) {
        if let itemIndex = savedItems.firstIndex(where: { $0.item.code == item.item.code }) {
            savedItems[itemIndex].dateSelector = item.dateSelector
            return
        }

        savedItems.append(item)
    }

    func dateSelector(of itemCode: String) -> LCWebViewModel.DateSelector? {
        return savedItems.first(where: { $0.item.code == itemCode })?.dateSelector
    }
}

extension LCWebSaver {
    struct Item {
        let item: LCWebViewModel.Item
        var dateSelector: LCWebViewModel.DateSelector
    }
}
