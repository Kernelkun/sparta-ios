//
//  ArbPlaygroundPricingCenterWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import Foundation
import NetworkingModels

class ArbsPlaygroundPCWireframe: BaseWireframe<ArbsPlaygroundPCViewController> {

    // MARK: - Initializers

    init(actionsDelegate: ArbsPlaygroundPCActionDelegate?) {
        let viewModel = ArbsPlaygroundPCViewModel()
        let viewController = ArbsPlaygroundPCViewController(viewModel: viewModel)
        super.init(viewController: viewController)

        viewController.actionsDelegate = actionsDelegate
        viewModel.delegate = viewController
    }
}
