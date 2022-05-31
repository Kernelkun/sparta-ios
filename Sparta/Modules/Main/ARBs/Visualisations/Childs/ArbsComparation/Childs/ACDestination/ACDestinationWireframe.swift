//
//  ACDestinationWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.04.2022.
//

import Foundation
import NetworkingModels

class ACDestinationWireframe: BaseWireframe<ACDestinationViewController> {

    // MARK: - Initializers

    init() {
        let viewModel = ACDestinationViewModel()
        let viewController = ACDestinationViewController(viewModel: viewModel)
        super.init(viewController: viewController)

        viewModel.delegate = viewController
    }
}
