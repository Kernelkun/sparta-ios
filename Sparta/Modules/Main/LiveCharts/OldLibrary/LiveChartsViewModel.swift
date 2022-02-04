//
//  LiveChartsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.01.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels

protocol LiveChartsViewModelDelegate: AnyObject {
    func didLoadData()
}

class LiveChartsViewModel: NSObject, BaseViewModel {

    // MARK: - Public proprties

    weak var delegate: LiveChartsViewModelDelegate?

    // MARK: - Private properties

    // MARK: - Public methods

    func loadData() {
        delegate?.didLoadData()
    }
}
