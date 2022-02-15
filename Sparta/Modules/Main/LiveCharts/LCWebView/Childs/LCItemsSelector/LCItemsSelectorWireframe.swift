//
//  LCItemsSelectorWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.02.2022.
//

import UIKit
import NetworkingModels

final class LCItemsSelectorWireframe: BaseWireframe<LCItemsSelectorViewController> {

    // MARK: - Initializers

    init(groups: [LCWebViewModel.Group], coordinatorDelegate: LCItemsSelectorViewCoordinatorDelegate?) {
        let viewModel = LCItemsSelectorViewModel(groups: groups)
        let viewController = LCItemsSelectorViewController(viewModel: viewModel)
        super.init(viewController: viewController)

        viewModel.delegate = viewController
        viewController.coordinatorDelegate = coordinatorDelegate
    }
}
