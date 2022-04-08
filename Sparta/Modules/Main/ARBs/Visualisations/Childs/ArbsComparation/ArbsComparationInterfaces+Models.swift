//
//  ArbsComparationInterfaces+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 31.03.2022.
//

import Foundation
import NetworkingModels

enum ArbsVACSortType: DisplayableItem, CaseIterable {
    case month
    case destination

    var title: String {
        switch self {
        case .month:
            return "By Month"

        case .destination:
            return "ARBs comparation"
        }
    }
}

struct ArbsComparationPCPUIModel {
    let headers: [Header]
    let arbsV: [ArbV]
    let selectedValueIdentifier: Identifier<String>?
}

extension ArbsComparationPCPUIModel {
    struct Header {
        let month: Month
        let units: String
    }

    struct Month: Equatable {
        let title: String
    }
}
