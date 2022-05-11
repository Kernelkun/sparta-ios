//
//  ArbsComparationInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import Foundation
import NetworkingModels

protocol ArbsComparationViewModelDelegate: AnyObject {
}

protocol ArbsComparationViewModelInterface {
    var delegate: ArbsComparationViewModelDelegate? { get set }
    var selectedSortType: ArbsVACSortType { get }

    func loadData()
}
