//
//  ArbPortfolio+PickerValued.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.04.2022.
//

import NetworkingModels

extension Arb.Portfolio: PickerValued {
    var title: String { name }
    var fullTitle: String { title }
}
