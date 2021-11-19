//
//  GetArbsPortfoliosRequest.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.11.2021.
//

import Foundation
import Networking
import NetworkingModels

struct GetArbsPortfoliosRequest: NetworkParameters {

    // MARK: - Public properties

    let bodyParameters: Parameters?
    let urlParameters: Parameters?
    var bodyEncoding: ParameterEncoding

    // MARK: - Initializers

    init(type: Arb.Portfolio.PortfolioType) {
        urlParameters = ["portfolioType": type.rawValue]
        bodyParameters = nil
        bodyEncoding = .urlEncoding
    }
}
