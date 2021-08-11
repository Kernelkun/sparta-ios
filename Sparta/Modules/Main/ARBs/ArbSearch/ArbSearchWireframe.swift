//
//  ArbSearchWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.08.2021.
//

import UIKit
import NetworkingModels

final class ArbSearchWireframe: BaseWireframe<ArbSearchViewController> {

    // MARK: - Initializers

    init(arbs: [Arb], coordinatorDelegate: ArbSearchControllerCoordinatorDelegate) {
        let viewModel = ArbSearchViewModel(arbs: arbs)
        let viewController = ArbSearchViewController(viewModel: viewModel, coordinatorDelegate: coordinatorDelegate)
        super.init(viewController: viewController)
        
        viewModel.delegate = viewController
    }

    // MARK: - Public methods

    func apply(arbs: [Arb]) {
        viewController.viewModel.apply(arbs: arbs)
    }
}
