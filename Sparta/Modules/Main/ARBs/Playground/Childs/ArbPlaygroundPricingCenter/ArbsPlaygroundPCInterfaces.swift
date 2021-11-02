//
//  ArbsPlaygroundPCInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.10.2021.
//

import Foundation

protocol ArbsPlaygroundPCViewModelDelegate: AnyObject {

}

protocol ArbsPlaygroundPCViewModelInterface {
    var delegate: ArbsPlaygroundPCViewModelDelegate? { get set }

    func loadData()
}
