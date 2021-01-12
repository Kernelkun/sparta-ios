//
//  PickerIdValued.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.12.2020.
//

import Foundation

struct PickerIdValued<K: Hashable>: PickerValued {

    // MARK: - Public properties

    var id: K
    var title: String
    var fullTitle: String
}

extension PickerIdValued: Equatable {

    static func == (lhs: PickerIdValued, rhs: PickerIdValued) -> Bool {
        lhs.id == rhs.id
    }
}
