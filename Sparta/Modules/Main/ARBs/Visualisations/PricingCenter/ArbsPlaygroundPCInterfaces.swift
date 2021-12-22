//
//  ArbsPlaygroundPCInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.10.2021.
//

import Foundation
import NetworkingModels

protocol ArbsPlaygroundPCViewModelDelegate: AnyObject {
    func arbsPlaygroundPCViewModelDidFetchSelectors(_ selectors: [ArbV.Selector])
}

protocol ArbsPlaygroundPCViewModelInterface {
    var delegate: ArbsPlaygroundPCViewModelDelegate? { get set }

    func loadData()
}
