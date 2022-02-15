//
//  LCDatesSelectorViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.02.2022.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol LCDatesSelectorViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didSuccessFetchList()
    func didSuccessChooseDate(_ dateSelector: LiveChartDateSelector)
}

class LCDatesSelectorViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LCDatesSelectorViewModelDelegate?

    private(set) var groups: [LCDatesSelectorViewModel.Group] = []
    private(set) var selectedDateSelector: LiveChartDateSelector?

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    // MARK: - Initializers

    init(dateSelectors: [LiveChartDateSelector], selectedDateSelector: LiveChartDateSelector? = nil) {
        self.groups = Dictionary(grouping: dateSelectors, by: { $0.group }).sorted { $0.key < $1.key }.compactMap { element in
            LCDatesSelectorViewModel.Group(name: element.key, dateSelectors: element.value)
        }
        self.selectedDateSelector = selectedDateSelector
    }

    // MARK: - Public methods

    func loadData() {
        onMainThread {
            self.delegate?.didSuccessFetchList()
        }
    }

    func chooseDate(_ dateSelector: LiveChartDateSelector) {
        self.selectedDateSelector = dateSelector
        delegate?.didSuccessChooseDate(dateSelector)
    }
}
