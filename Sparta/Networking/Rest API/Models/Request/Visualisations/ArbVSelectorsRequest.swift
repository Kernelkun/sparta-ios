//
//  ArbVSelectorsRequest.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.10.2021.
//

import Networking

struct ArbVSelectorsRequest: NetworkParameters {

    // MARK: - Public properties

    let bodyParameters: Parameters?
    let urlParameters: Parameters?
    var bodyEncoding: ParameterEncoding

    // MARK: - Initializers

    init(type: SelectorType) {
        urlParameters = ["type": type.rawValue]
        bodyParameters = nil
        bodyEncoding = .urlEncoding
    }
}

extension ArbVSelectorsRequest {
    enum SelectorType: String {
        case pricingCenter
        case comparisonByDestination
    }
}
