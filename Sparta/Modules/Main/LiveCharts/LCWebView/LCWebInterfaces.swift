//
//  LCWebInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import Foundation
import NetworkingModels

protocol LCWebViewModelDelegate: AnyObject {
    func didChangeLoadingState(_ isLoading: Bool)
    func didCatchAnError(_ error: String)
    func didSuccessUpdateConfigurator(_ configurator: LCWebViewModel.Configurator)
    func didSuccessUpdateDateSelector(_ dateSelector: LCWebViewModel.DateSelector)
    func didSuccessUpdateHighlights(_ highlights: [LCWebViewModel.Highlight])
}

protocol LCWebViewModelInterface: AnyObject {
    var delegate: LCWebViewModelDelegate? { get set }
    var configurator: LCWebViewModel.Configurator? { get }
    var groups: [LCWebViewModel.Group] { get }

    func loadData()
    func startLive()
    func stopLive()
    func apply(configurator: LCWebViewModel.Configurator)
    func setDate(_ dateSelector: LCWebViewModel.DateSelector)
}
