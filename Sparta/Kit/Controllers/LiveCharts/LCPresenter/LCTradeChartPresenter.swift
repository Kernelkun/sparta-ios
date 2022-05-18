//
//  LCTradeChartPresenter.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.02.2022.
//

import UIKit
import SpartaHelpers

class LCTradeChartPresenter {

    // MARK: - Private properties

    private var configurator: Configurator!
    private var productCode: String!
    private var dateCode: String?

    private var window: UIWindow?
    private let lcWebTradeController = LCWebTradeViewController(edges: .zero)

    // MARK: - Initializers

    init() {
        lcWebTradeController.delegate = self

        lcWebTradeController.resizeButton = TappableButton().then { button in

            button.backgroundColor = .neutral80
        }
    }

    // MARK: - Public methods

    func present(configurator: Configurator, productCode: String, dateCode: String?) {
        self.configurator = configurator
        self.productCode = productCode
        self.dateCode = dateCode

        switch configurator.state {
        case .minimized:
            presentMinimized()

        case .fullScreen(let orientation):
            presentFullScreen(orientation: orientation)
        }
    }

    func presentFullScreen(orientation: UIInterfaceOrientation) {
        guard !configurator.state.isFullScreen else { return }

        // change state
        configurator.state = .fullScreen(orientation: orientation)

        // remove from parrent
        lcWebTradeController.resizeButton.removeFromSuperview()
        lcWebTradeController.remove()

        // rotate screen
        InterfaceOrientationUtility.lockOrientation(.all, rotateTo: orientation)

        let edges: UIEdgeInsets

        if !UIApplication.isDeviceWithSafeArea {
            edges = .zero
        } else {
            edges = UIApplication.safeAreaInsets
        }

        lcWebTradeController.updateEdges(edges)
        lcWebTradeController.load(configurator: .init(productCode: productCode, dateCode: dateCode, isPortraitMode: false))

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = lcWebTradeController
        window?.windowLevel = UIWindow.Level.normal + 2
        window?.makeKeyAndVisible()

        lcWebTradeController.resizeButton.do { button in

            button.setImage(UIImage(named: "ic_chart_collapse"), for: .normal)
            button.onTap { [unowned self] _ in
                InterfaceOrientationUtility.lockOrientation(.all, rotateTo: .portrait)
                presentMinimized()
            }

            window?.addSubview(button) {
                $0.size.equalTo(32)
                $0.bottom.equalToSuperview().inset(edges.bottom + 44)
                $0.right.equalToSuperview().inset(edges.right + 6)
            }
        }
    }

    func presentMinimized() {
        // change state
        configurator.state = .minimized

        // remove from parrent
        lcWebTradeController.resizeButton.removeFromSuperview()
        window?.rootViewController = nil
        window = nil

        // add to parrent
        configurator.parrentViewController.add(
            lcWebTradeController,
            to: configurator.contentView
        )

        // main controller settings
        lcWebTradeController.updateEdges(.zero)
        lcWebTradeController.load(configurator: .init(productCode: productCode, dateCode: dateCode, isPortraitMode: true))

        lcWebTradeController.resizeButton.do { button in

            button.setImage(UIImage(named: "ic_chart_expand"), for: .normal)
            button.onTap { [unowned self] _ in
                presentFullScreen(orientation: .landscapeRight)
            }

            lcWebTradeController.view.addSubview(button) {
                $0.size.equalTo(32)
                $0.top.equalToSuperview().inset(70)
                $0.left.equalToSuperview().offset(6)
            }
        }
    }

    func reloadContent() {
        lcWebTradeController.reloadContent()
    }
}

extension LCTradeChartPresenter: LCWebTradeViewDelegate {

    func lcWebTradeViewControllerDidChangeContentOffset(_ viewController: LCWebTradeViewController, offset: CGFloat, direction: MovingDirection) {
    }

    func lcWebTradeViewControllerDidTapOnHLView(_ viewController: LCWebTradeViewController) {
    }

    func lcWebTradeViewControllerDidChangeMenuState(_ viewController: LCWebTradeViewController, isMenuOpen: Bool) {
        self.lcWebTradeController.resizeButton.isHidden = isMenuOpen
        viewController.resizeButton.isHidden = isMenuOpen
    }

    func lcWebTradeViewControllerDidChangeOrientation(_ viewController: LCWebTradeViewController, interfaceOrientation: UIInterfaceOrientation) {
        guard interfaceOrientation.isPortrait else { return }

        presentMinimized()
    }
}
