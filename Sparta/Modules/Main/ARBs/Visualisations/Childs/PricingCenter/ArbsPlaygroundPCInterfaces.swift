//
//  ArbsPlaygroundPCInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.10.2021.
//

import Foundation
import NetworkingModels

enum ArbsPlaygroundPCLoadingModule {
    case arbsSelector
    case pricingCenterContent
}

protocol ArbsPlaygroundPCViewModelDelegate: AnyObject {
    func arbsPlaygroundPCViewModelDidChangeLoadingState(_ isLoading: Bool, module: ArbsPlaygroundPCLoadingModule)
    func arbsPlaygroundPCViewModelDidFetchSelectors(_ selectors: [ArbV.Selector])
    func arbsPlaygroundPCViewModelDidFetchArbsVModel(_ model: ArbsPlaygroundPCPUIModel)
    func arbsPlaygroundPCViewModelDidChangeActiveArbVValue(_ model: ArbsPlaygroundPCPUIModel)
}

protocol ArbsPlaygroundPCViewModelInterface {
    var delegate: ArbsPlaygroundPCViewModelDelegate? { get set }
    var arbsV: [ArbV] { get }

    func loadData()
    func makeActiveArbVSelector(_ arbVSelector: ArbV.Selector)
    func makeActiveModel(_ activeModel: ArbsPlaygroundPCPUIModel.Active)
}
