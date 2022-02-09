//
//  LCWebViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.02.2022.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol LCWebViewModelDelegate: AnyObject {
    func didChangeLoadingState(_ isLoading: Bool)
    func didCatchAnError(_ error: String)
    func didLoadCells(_ cells: [ArbDetailViewModel.Cell])
    func didReloadCells(_ cells: [ArbDetailViewModel.Cell])
}

class LCWebViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LCWebViewModelDelegate?

    // MARK: - Initializers

    override init() {
        super.init()
    }

    deinit {
    }
}
