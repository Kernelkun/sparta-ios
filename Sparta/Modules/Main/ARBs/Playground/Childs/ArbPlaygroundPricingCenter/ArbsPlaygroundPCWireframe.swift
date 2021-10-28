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

    init() {
        let viewController = ArbsPlaygroundPCViewController()
        super.init(viewController: viewController)
    }
}
