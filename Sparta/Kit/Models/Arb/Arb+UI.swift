//
//  Arb+UI.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.10.2021.
//

import NetworkingModels

extension Arb {

    var presentationMonthsCount: Int {
        portfolio.isAra ? 6 : 2
    }
}
