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
}

extension ArbsPlaygroundPCPUIModel {
    struct Header {
        let month: Month
        let units: String
    }

    struct Month: Equatable {
        let title: String
    }
}
