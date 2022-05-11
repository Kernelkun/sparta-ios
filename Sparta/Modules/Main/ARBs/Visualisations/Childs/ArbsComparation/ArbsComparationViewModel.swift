//
//  ArbsComparationViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import Foundation
import NetworkingModels

class ArbsComparationViewModel: ArbsComparationViewModelInterface {

    // MARK: - Public properties

    weak var delegate: ArbsComparationViewModelDelegate?

    var selectedSortType: ArbsVACSortType = .deliveryDate

    // MARK: - Public methods

    func loadData() {
    }
}
