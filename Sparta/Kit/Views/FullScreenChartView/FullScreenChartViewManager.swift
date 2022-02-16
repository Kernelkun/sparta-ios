//
//  FullScreenChartViewManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.02.2022.
//

import UIKit
import SpartaHelpers

class FullScreenChartViewManager {

    // MARK: - Private properties

    private var window: UIWindow?
    private var isPresented: Bool = false

    // MARK: - Public methods

    func show(productCode: String, dateCode: String?) {
        guard !isPresented else { return }

        isPresented = true
        InterfaceOrientationUtility.lockOrientation(.landscape, rotateTo: .landscapeRight)

        let edges: UIEdgeInsets

        if !UIApplication.isDeviceWithSafeArea {
            edges = .zero
        } else {
            edges = UIApplication.safeAreaInsets
        }

        let controller = LCWebTradeViewController(edges: edges)
        controller.load(configurator: .init(productCode: productCode, dateCode: dateCode))

        _ = TappableButton().then { button in

            button.backgroundColor = .neutral80
            button.setImage(UIImage(named: "ic_chart_collapse"), for: .normal)
            button.onTap { [unowned self] _ in
                InterfaceOrientationUtility.lockOrientation(.portrait, rotateTo: .portrait)
                hide()
            }

            controller.view.addSubview(button) {
                $0.size.equalTo(40)
                $0.bottom.equalToSuperview().inset(edges.bottom + 24)
                $0.right.equalToSuperview().inset(edges.right)
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
