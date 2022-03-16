//
//  FullScreenChartViewManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.02.2022.
//

import UIKit
import SpartaHelpers

class FullScreenChartViewManager {

    // MARK: - Public properties

    private(set) var isPresented: Bool = false

    // MARK: - Private properties

    private var window: UIWindow?

    // MARK: - Public methods

    func show(productCode: String, dateCode: String?, orientation: UIInterfaceOrientation) {
        guard !isPresented else { return }

        isPresented = true
        InterfaceOrientationUtility.lockOrientation(.all, rotateTo: orientation)

        let edges: UIEdgeInsets

        if !UIApplication.isDeviceWithSafeArea {
            edges = .zero
        } else {
            edges = UIApplication.safeAreaInsets
        }

        let controller = LCWebTradeViewController(edges: edges)
        controller.load(configurator: .init(productCode: productCode, dateCode: dateCode, isPortraitMode: false))
        controller.delegate = self

        _ = TappableButton().then { button in

            button.backgroundColor = .neutral80
            button.setImage(UIImage(named: "ic_chart_collapse"), for: .normal)
            button.onTap { [unowned self] _ in
                InterfaceOrientationUtility.lockOrientation(.all, rotateTo: .portrait)
                hide()
            }

            controller.view.addSubview(button) {
                $0.size.equalTo(32)
                $0.bottom.equalToSuperview().inset(edges.bottom + 44)
                $0.right.equalToSuperview().inset(edges.right + 6)
            }
        }

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

    func lcWebTradeViewControllerDidTapOnHLView(_ viewController: LCWebTradeViewController) {

    }

    func lcWebTradeViewControllerDidChangeOrientation(_ viewController: LCWebTradeViewController, interfaceOrientation: UIInterfaceOrientation) {
        guard interfaceOrientation.isPortrait else { return }

        InterfaceOrientationUtility.lockOrientation(.all, rotateTo: .portrait)
        hide()
    }
}
