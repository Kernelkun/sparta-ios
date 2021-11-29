//
//  ArbsVContentWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 24.11.2021.
//

import UIKit
import NetworkingModels

final class ArbsVContentWireframe: BaseWireframe<ArbsVContentViewController> {

    // MARK: - Initializers

    init(selectedArb: Arb) {
//        let viewModel = ArbsPlaygroundViewModel(selectedArb: selectedArb)
        let viewController = ArbsVContentViewController()
        super.init(viewController: viewController)

//        viewModel.delegate = viewController
    }
}
