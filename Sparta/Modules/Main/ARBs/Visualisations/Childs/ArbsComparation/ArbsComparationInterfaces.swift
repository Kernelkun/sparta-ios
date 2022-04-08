//
//  ArbsComparationInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import Foundation
import NetworkingModels

protocol ArbsComparationViewModelDelegate: AnyObject {
    func arbsComparationViewModelDidFetchDestinationSelectors(_ selectors: [ArbV.Selector])
    func arbsComparationViewModelDidFetchArbsVModel(_ model: ArbsComparationPCPUIModel)
}

protocol ArbsComparationViewModelInterface {
    var delegate: ArbsComparationViewModelDelegate? { get set }

    func loadData()
    func makeActiveArbVSelector(_ arbVSelector: ArbV.Selector)
}
