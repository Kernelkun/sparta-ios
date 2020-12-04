//
//  BlenderMonthDetailModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.12.2020.
//

import Foundation

struct BlenderMonthDetailModel {

    // MARK: - Public properties

    let mainKeyValues: [String: String]
    let componentsKeyValues: [String: String]

    func printDescription() {
        print("Top block description:")
        print(mainKeyValues.debugDescription)

        print("Components block description:")
        print(componentsKeyValues.debugDescription)
    }
}
