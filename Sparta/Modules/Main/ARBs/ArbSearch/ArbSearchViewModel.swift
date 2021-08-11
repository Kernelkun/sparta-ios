//
//  ArbSearchViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.08.2021.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

class ArbSearchViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: ArbSearchViewModelDelegate?

    private(set) var arbs: [Arb]

    // MARK: - Private properties

    private var searchRequest: String?
    private var initialArbs: [Arb]

    // MARK: - Initializers

    init(arbs: [Arb]) {
        self.arbs = arbs
        self.initialArbs = arbs
    }

    // MARK: - Public methods

    func apply(arbs: [Arb]) {
        self.arbs = arbs
        self.initialArbs = arbs

        search(query: searchRequest)
    }

    func search(query: String?) {

        func notify() {
            onMainThread {
                self.delegate?.didSuccessLoadArbsList()
            }
        }

        guard let query = query, !query.isEmpty else {
            arbs = initialArbs
            notify()
            return
        }

        searchRequest = query
        arbs = filtered(by: searchRequest)

        notify()
    }

    func title(for arb: Arb) -> String {
        arb.grade + " | " + arb.dischargePortName + " | " + arb.freightType
    }

    // MARK: - Private methods

    private func filtered(by searchRequest: String?) -> [Arb] {
        guard let searchRequest = searchRequest else { return initialArbs }

        return initialArbs.filter { arb in
            arb.grade.lowercased().contains(searchRequest.lowercased())
        }
    }
}
