//
//  ArbsVContentInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2021.
//

import Foundation

protocol ArbsVContentControllerObserver: AnyObject {
    func arbsVContentControllerDidChangeScrollState(_ controller: ArbsVContentControllerInterface, newState: AVBarController.State)
}

protocol ArbsVContentControllerInterface: AnyObject {
    var airBar: ArbVHeaderView! { get }

    func addObserver(_ observer: ArbsVContentControllerObserver)
    func removeObserver(_ observer: ArbsVContentControllerObserver)
}
