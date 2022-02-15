//
//  LCDatesSelectorViewModel+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.02.2022.
//

import Foundation
import NetworkingModels

extension LCDatesSelectorViewModel {

    struct Group {
        let name: String
        let dateSelectors: [LiveChartDateSelector]
    }
}
