//
//  LCItemsSelectorViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol LCItemsSelectorViewModelDelegate: AnyObject {
    func didCatchAnError(_ error: String)
    func didChangeLoadingState(_ isLoading: Bool)
    func didSuccessFetchList()
    func didSuccessChooseItem(_ item: LCWebViewModel.Item)
}

class LCItemsSelectorViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: LCItemsSelectorViewModelDelegate?
    var groups: [LCWebViewModel.Group] = []

    // MARK: - Private properties

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private var initialLoadedGroups: [LCWebViewModel.Group] = []
    private var searchRequest: String?

    // MARK: - Initializers

    init(groups: [LCWebViewModel.Group]) {
        self.groups = groups
        self.initialLoadedGroups = groups
    }

    // MARK: - Public methods

    func loadData() {
        onMainThread {
            self.delegate?.didSuccessFetchList()
        }
    }

    func search(query: String?) {

        func notify() {
            onMainThread {
                self.delegate?.didSuccessFetchList()
            }
        }

        guard let query = query, !query.isEmpty else {
            groups = initialLoadedGroups
            notify()
            return
        }

        searchRequest = query
        groups = initialLoadedGroups.filtered(by: searchRequest)

        notify()
    }

    func chooseItem(_ item: LCWebViewModel.Item) {
        delegate?.didSuccessChooseItem(item)
    }
}
