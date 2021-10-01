//
//  ArbDetailWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.09.2021.
//

import UIKit
import NetworkingModels

final class ArbDetailWireframe: BaseWireframe<ArbDetailViewController> {

    // MARK: - Initializers

    init(selectedArb: Arb) {
        let viewController = ArbDetailViewController(arb: selectedArb)
        super.init(viewController: viewController)
    }
}
