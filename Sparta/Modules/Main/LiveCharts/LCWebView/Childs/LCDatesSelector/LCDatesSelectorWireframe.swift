//
//  LCDatesSelectorWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.02.2022.
//

import UIKit
import NetworkingModels

final class LCDatesSelectorWireframe: BaseWireframe<LCDatesSelectorViewController> {

    // MARK: - Initializers

    init(
        dateSelectors: [LiveChartDateSelector],
        selectedDateSelector: LiveChartDateSelector?,
        coordinatorDelegate: LCDatesSelectorViewCoordinatorDelegate
    ) {
        let viewModel = LCDatesSelectorViewModel(dateSelectors: dateSelectors, selectedDateSelector: selectedDateSelector)
        let viewController = LCDatesSelectorViewController(viewModel: viewModel)
        super.init(viewController: viewController)

        viewModel.delegate = viewController
        viewController.coordinatorDelegate = coordinatorDelegate
    }
}
