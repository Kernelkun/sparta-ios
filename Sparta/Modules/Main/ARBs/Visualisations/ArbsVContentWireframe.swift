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

    init() {
        let viewModel = ArbsVContentViewModel()
        let viewController = ArbsVContentViewController(viewModel: viewModel)

        let configurator = ArbsVContentViewController.Configurator(
            pcChildController: ArbsVChildPCViewController(parrentController: viewController),
            acChhildController: ArbsVChildACViewController(parrentController: viewController)
        )

        viewController.configurator = configurator

        super.init(viewController: viewController)
    }
}
