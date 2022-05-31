//
//  ArbsVContentInterfaces.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2021.
//

import Foundation
import NetworkingModels
import UIKit

enum ArbsVContentPage: DisplayableItem, CaseIterable {
    case pricingCenter
    case arbsComparation

    var title: String {
        switch self {
        case .pricingCenter:
            return "Pricing center"

        case .arbsComparation:
            return "ARBs comparation"
        }
    }
}

protocol ArbsVContentControllerObserver: AnyObject {
    func arbsVContentControllerDidChangeScrollState(
        _ controller: ArbsVContentControllerInterface,
        newState: AVBarController.State,
        page: ArbsVContentPage
    )

    func arbsVContentControllerDidChangePage(
        _ controller: ArbsVContentControllerInterface,
        newPage: ArbsVContentPage
    )
}

protocol ArbsVContentControllerInterface: AnyObject {
    var airBar: ArbVHeaderView! { get }
    var contentScrollView: UIScrollView! { get }

    func addObserver(_ observer: ArbsVContentControllerObserver)
    func removeObserver(_ observer: ArbsVContentControllerObserver)
}

//
//protocol ArbsVContentViewModelDelegate: AnyObject {
//    func arbsPlaygroundPCViewModelDidFetchSelectors(_ selectors: [ArbV.Selector])
//}

protocol ArbsVContentViewModelInterface {
//    var delegate: ArbsVContentViewModelDelegate? { get set }

    func startLoadDataForPC()
    func startLoadDataForAC()
    func stopLoadData()
}
