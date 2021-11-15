//
//  UpdateArbsPIOrderRequest.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.11.2021.
//

import Foundation
import Networking
import NetworkingModels

struct UpdateArbsPIOrderRequest: NetworkParameters {

    // MARK: - Public properties

    let bodyParameters: Parameters?
    let urlParameters: Parameters?
    var bodyEncoding: ParameterEncoding

    let portfolio: Arb.Portfolio

    // MARK: - Initializers

    init(portfolio: Arb.Portfolio, orders: [Parameters]) {
        self.portfolio = portfolio

        urlParameters = nil
        bodyParameters = ["order": orders]
        bodyEncoding = .jsonEncoding
    }
}
