//
//  ACDeliveryDateWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.04.2022.
//

import Foundation
import NetworkingModels

class ACDeliveryDateWireframe: BaseWireframe<ACDeliveryDateViewController> {

    // MARK: - Initializers

    init() {
        let viewModel = ACDeliveryDateViewModel()
        let viewController = ACDeliveryDateViewController(viewModel: viewModel)
        super.init(viewController: viewController)

        viewModel.delegate = viewController
    }
}
