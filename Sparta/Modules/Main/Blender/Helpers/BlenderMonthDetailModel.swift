//
//  BlenderMonthDetailModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.12.2020.
//

import Foundation

struct BlenderMonthDetailModel {

    // MARK: - Public properties

    var mainKeyValues: [KeyValueParameter]
    var componentsKeyValues: [KeyValueParameter]
}

extension BlenderMonthDetailModel {

    struct KeyValueParameter {
        let key: String
        let value: String
        let priorityIndex: Int
    }
}
