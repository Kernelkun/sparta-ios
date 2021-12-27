//
//  ArbsComparationInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import Foundation
import NetworkingModels

protocol ArbsComparationViewModelDelegate: AnyObject {
    func arbsPlaygroundPCViewModelDidFetchSelectors(_ selectors: [ArbV.Selector])
}

protocol ArbsComparationViewModelInterface {
    var delegate: ArbsComparationViewModelDelegate? { get set }

    func loadData()
}
