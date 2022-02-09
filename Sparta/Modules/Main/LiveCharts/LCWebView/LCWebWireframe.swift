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
        let viewController = LCWebViewController()
        super.init(viewController: viewController)
    }
}
