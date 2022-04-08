//
//  ArbsVChildPCViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2021.
//

import UIKit

class ArbsVChildPCViewController: ArbsVChildViewController {

    // MARK: - Private properties

    private let pcWireframe = ArbsPlaygroundPCWireframe()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func arbsVContentControllerDidChangeScrollState(
        _ controller: ArbsVContentControllerInterface,
        newState: AVBarController.State,
        page: ArbsVContentPage
    ) {
        super.arbsVContentControllerDidChangeScrollState(controller, newState: newState, page: page)

        guard page == .pricingCenter else { return }

        print("Direction: " + "\(newState.direction)" + " " + "contentOffset.y" + "\(newState.contentOffset.y)")

        if newState.direction == .down
            && newState.contentOffset.y > 0 {

//            parrentController.airBar.middleContentView.isHidden = false
        }

//        parrentController.airBar.applyState(isMinimized: false)
//        parrentController.airBar.topRightContentView.backgroundColor = .red
    }

    override func arbsVContentControllerDidChangePage(
        _ controller: ArbsVContentControllerInterface,
        newPage: ArbsVContentPage
    ) {
        super.arbsVContentControllerDidChangePage(controller, newPage: newPage)

        guard newPage == .pricingCenter else { return }

        let topContentView = parrentController.airBar.topRightContentView
        topContentView?.removeAllSubviews()
        topContentView?.addSubview(pcWireframe.viewController.airBarTopMenu) {
            $0.edges.equalToSuperview()
        }

//        parrentController.airBar.topRightContentView.backgroundColor = .red
    }

    // MARK: - Private methods

    private func setupUI() {
        add(pcWireframe.viewController, to: view)
    }
}
