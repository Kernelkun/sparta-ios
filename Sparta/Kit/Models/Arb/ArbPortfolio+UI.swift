//
//  ArbPortfolio+UI.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.10.2021.
//

import NetworkingModels

extension Arb.Portfolio {

    var descriptionText: String? {
        if self.isAra {
            return "ArbsPage.Portfolio.Ara.Description".localized
        } else if self.isHou {
            return "ArbsPage.Portfolio.Hou.Description".localized
        }

        return nil
    }
}
