//
//  ArbsPlaygroundPCInterfaces+Models.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 22.03.2022.
//

import Foundation
import NetworkingModels

struct ArbsPlaygroundPCPUIModel {
    let headers: [Header]
    let arbsV: [ArbV]
    var active: Active
}

extension ArbsPlaygroundPCPUIModel {
    struct Month: Equatable {
        let title: String
    }

    struct Header {
        let month: Month
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
