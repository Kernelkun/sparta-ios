//
//  ArbsVChildACViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2021.
//

import UIKit

class ArbsVChildACViewController: ArbsVChildViewController {

    // MARK: - Private properties

    private let acWireframe = ArbsComparationWireframe()

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

        //        parrentController.airBar.applyState(isMinimized: transitionProgress < 1)
        //        parrentController.airBar.topRightContentView.backgroundColor = .yellow
    }

    override func arbsVContentControllerDidChangePage(
        _ controller: ArbsVContentControllerInterface,
        newPage: ArbsVContentPage
    ) {
        super.arbsVContentControllerDidChangePage(controller, newPage: newPage)

        guard newPage == .arbsComparation else { return }

        parrentController.airBar.applyState(isMinimized: false)

        parrentController.airBar.snp.updateConstraints {
            $0.height.equalTo(100)
        }

        // adding top menu

        let topContentView = parrentController.airBar.topRightContentView
        topContentView?.removeAllSubviews()
        topContentView?.addSubview(acWireframe.viewController.airBarTopMenu) {
            $0.edges.equalToSuperview()
        }

        // adding bottom menu

        let bottomContentView = parrentController.airBar.bottomContentView
        bottomContentView?.removeAllSubviews()
        bottomContentView?.addSubview(acWireframe.viewController.airBarBottomMenu) {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .clear
        add(acWireframe.viewController, to: view)
    }
}
