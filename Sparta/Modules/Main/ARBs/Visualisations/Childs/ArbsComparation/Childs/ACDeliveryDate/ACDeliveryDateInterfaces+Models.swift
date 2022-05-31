//
//  ACDeliveryDateInterfaces+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.05.2022.
//

import Foundation
import NetworkingModels

struct MonthsSelector {

    // MARK: - Public properties

    let months: [String]
    var month: String { months[selectedIndex] }

    var ableSwitchToPrevMonth: Bool {
        selectedIndex > 0
    }

    var ableSwitchToNextMonth: Bool {
        selectedIndex != months.count - 1
    }

    // MARK: - Private properties

    private var selectedIndex: Int

    // MARK: - Initializers

    init(months: [String]) {
        self.months = months
        self.selectedIndex = 0
    }

    // MARK: - Public properties

    mutating func switchToPrevMonth() {
        self.selectedIndex -= 1
    }

    mutating func switchToNextMonth() {
        self.selectedIndex += 1
    }
}

struct ACDeliveryDateUIModel {
    let headers: [Header]
    let rows: [Row]
    var active: Active
}

extension ACDeliveryDateUIModel {
    struct ArbVGroup {
        let grade: String
        let arbsV: [ArbV]
    }

    struct Row {
        let title: String
        let groups: [ArbVGroup]
    }

    struct Header {
        let title: String
        let units: String
    }

    struct Active {
        let arbV: ArbV
        let arbVValue: ArbV.Value

        var month: String { arbVValue.deliveryMonth }
        var identifier: Identifier<String> {
            arbV.uniqueIdentifier(from: arbVValue)
        }
    }
}
