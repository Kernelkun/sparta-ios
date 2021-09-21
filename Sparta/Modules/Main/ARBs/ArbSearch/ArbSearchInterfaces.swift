//
//  ArbSearchInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.08.2021.
//

import Foundation
import NetworkingModels

protocol ArbSearchControllerCoordinatorDelegate: AnyObject {
    func arbSearchControllerDidChoose(arb: Arb)
}

protocol ArbSearchViewModelDelegate: AnyObject {
    func didSuccessLoadArbsList()
}

