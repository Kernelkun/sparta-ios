//
//  ACDestinationInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.04.2022.
//

import Foundation
import NetworkingModels

protocol ACDestinationViewModelDelegate: AnyObject {
    func acDestinationViewModelDidChangeLoadingState(_ isLoading: Bool)
    func acDestinationViewModelDidFetchDestinationSelectors(_ selectors: [ArbV.Selector])
    func acDestinationViewModelDidFetchArbsVModel(_ model: ArbsComparationPCPUIModel)
    func acDestinationViewModelDidChangeActiveArbVValue(_ model: ArbsComparationPCPUIModel)
}

protocol ACDestinationViewModelInterface {
    var delegate: ACDestinationViewModelDelegate? { get set }

    func loadData()
    func makeActiveArbVSelector(_ arbVSelector: ArbV.Selector)
    func makeActiveModel(_ activeModel: ArbsComparationPCPUIModel.Active)
}
