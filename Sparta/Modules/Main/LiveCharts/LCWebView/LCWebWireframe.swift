//
//  LCWebWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.02.2022.
//

import UIKit
import NetworkingModels

final class LCWebWireframe: BaseWireframe<LCWebViewController> {

    // MARK: - Initializers

    init() {
        let viewModel = LCWebViewModel()
        let viewController = LCWebViewController(viewModel: viewModel)
        super.init(viewController: viewController)

        viewModel.delegate = viewController
    }
}
