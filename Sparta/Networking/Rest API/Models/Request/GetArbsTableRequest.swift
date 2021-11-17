//
//  GetArbsTableRequest.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.11.2021.
//

import Foundation
import Networking
import NetworkingModels

struct GetArbsTableRequest: NetworkParameters {

    // MARK: - Public properties

    let bodyParameters: Parameters?
    let urlParameters: Parameters?
    var bodyEncoding: ParameterEncoding

    // MARK: - Initializers

    init(portfolios: [Arb.Portfolio]) {
        urlParameters = ["portfolioIds": portfolios.compactMap { String($0.id) }.joined(separator: ",")]
        bodyParameters = nil
        bodyEncoding = .urlEncoding
    }
}
