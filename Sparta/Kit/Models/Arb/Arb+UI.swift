//
//  Arb+UI.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.10.2021.
//

import NetworkingModels

extension Arb {

    var presentationMonthsCount: Int {
        if portfolio.isAra {
            return 6
        } else {
            guard let user = App.instance.currentUser else { return 2 }

            return user.houArbMonths
        }
    }
}
