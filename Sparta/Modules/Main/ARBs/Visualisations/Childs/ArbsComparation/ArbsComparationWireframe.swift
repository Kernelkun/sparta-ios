//
//  ArbsComparationWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import Foundation
import NetworkingModels

class ArbsComparationWireframe: BaseWireframe<ArbsComparationViewController> {

    // MARK: - Initializers

    init() {
        let viewModel = ArbsComparationViewModel()
        let viewController = ArbsComparationViewController(viewModel: viewModel)
        super.init(viewController: viewController)

        viewModel.delegate = viewController
    }
}
