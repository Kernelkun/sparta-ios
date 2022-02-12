//
//  FullScreenChartViewManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.02.2022.
//

import UIKit

class FullScreenChartViewManager {

    // MARK: - Private properties

    private var window: UIWindow?
    private var isPresented: Bool = false

    // MARK: - Public methods

    func show() {
        guard !isPresented else { return }

        isPresented = true

        let controller = LCWebTradeViewController(buttonType: .collapse)
        controller.delegate = self

        InterfaceOrientationUtility.lockOrientation(.landscape, rotateTo: .landscapeRight)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controller
        window?.windowLevel = UIWindow.Level.normal + 2
        window?.makeKeyAndVisible()
    }

    func hide() {
        guard isPresented else { return }

        isPresented = false
        window = nil
    }
}

extension FullScreenChartViewManager: LCWebTradeViewDelegate {

    func lcWebTradeViewControllerDidChangeContentOffset(_ viewController: LCWebTradeViewController, offset: CGFloat, direction: MovingDirection) {
    }

    func lcWebTradeViewControllerDidTapSizeButton(_ viewController: LCWebTradeViewController, buttonType: LCWebTradeViewController.ButtonType) {
        InterfaceOrientationUtility.lockOrientation(.portrait, rotateTo: .portrait)
        hide()
    }
}
