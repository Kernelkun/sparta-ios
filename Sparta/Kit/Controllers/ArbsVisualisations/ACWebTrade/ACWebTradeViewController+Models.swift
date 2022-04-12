//
//  ACWebTradeViewController+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.04.2022.
//

import UIKit
import App

extension ACWebTradeViewController {
    struct Configurator {
        let arbIds: [Int]
        let dateRange: Environment.Visualisations.DateRange
        let deliveryWindow: String?
        let deliveryMonth: String?
    }
}
