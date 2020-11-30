//
//  SpartaError.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

public enum SpartaError: Error, Equatable {

    // general
    case unknown
    case error400

    case custom(description: String)
    case invalidNetworkConnection

    // main flow

    public init(code: Int) {
        switch code {
        case 400: self = .error400
        default: self = .unknown
        }
    }
}

