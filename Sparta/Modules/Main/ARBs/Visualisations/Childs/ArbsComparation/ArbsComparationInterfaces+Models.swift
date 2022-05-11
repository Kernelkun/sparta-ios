//
//  ArbsComparationInterfaces+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 31.03.2022.
//

import Foundation
import NetworkingModels

enum ArbsVACSortType: DisplayableItem, CaseIterable {
    case deliveryDate
    case destination

    var title: String {
        switch self {
        case .deliveryDate:
            return "By Delivery Date"

        case .destination:
            return "By Destination"
        }
    }
}

struct ArbsComparationPCPUIModel {
    let headers: [Header]
    let arbsV: [ArbV]
    var active: Active
}

extension ArbsComparationPCPUIModel {
    struct Header {
        let month: Month
        let units: String
    }

    struct Month: Equatable {
        let title: String
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
