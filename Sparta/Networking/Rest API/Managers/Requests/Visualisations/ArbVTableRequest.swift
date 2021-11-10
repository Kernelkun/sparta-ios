//
//  ArbVTableRequest.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.11.2021.
//

import Networking
import NetworkingModels

struct ArbVTableRequest: NetworkParameters {

    // MARK: - Public properties

    let bodyParameters: Parameters?
    let urlParameters: Parameters?
    var bodyEncoding: ParameterEncoding

    // MARK: - Initializers

    init(arbIds: [Int]) {
        urlParameters = ["arbIds": arbIds.compactMap { $0.toString }.joined(separator: ",")]
        bodyParameters = nil
        bodyEncoding = .urlEncoding
    }
}
