//
//  ArbsPlaygroundWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.09.2021.
//

import UIKit
import NetworkingModels

final class ArbsPlaygroundWireframe: BaseWireframe<ArbsPlaygroundViewController> {

    // MARK: - Initializers

    init(selectedArb: Arb) {
        let viewModel = ArbsPlaygroundViewModel(selectedArb: selectedArb)
        let viewController = ArbsPlaygroundViewController(viewModel: viewModel)
        super.init(viewController: viewController)

        viewModel.delegate = viewController
    }
}
