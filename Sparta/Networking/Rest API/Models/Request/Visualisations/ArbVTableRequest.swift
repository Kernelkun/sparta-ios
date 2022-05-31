//
//  ArbVTableRequest.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.11.2021.
//

import App
import Networking
import NetworkingModels

struct ArbVTableRequest: NetworkParameters {

    // MARK: - Public properties

    let bodyParameters: Parameters?
    let urlParameters: Parameters?
    var bodyEncoding: ParameterEncoding

    // MARK: - Initializers

    init(arbIds: [Int]? = nil, portfolioId: Int? = nil, dateRange: Environment.Visualisations.DateRange? = nil) {

        var urlParameters: Parameters = [:]

        if let arbIds = arbIds {
            urlParameters["arbIds"] = arbIds.compactMap { $0.toString }.joined(separator: ",")
        }

        if let portfolioId = portfolioId {
            urlParameters["portfolioId"] = portfolioId
        }

        if let dateRange = dateRange {
            urlParameters["dateRange"] = dateRange.rawValue
        }

        self.urlParameters = urlParameters
        bodyParameters = nil
        bodyEncoding = .urlEncoding
    }
}
