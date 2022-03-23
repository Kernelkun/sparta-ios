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

        let topContentView = parrentController.airBar.topRightContentView
        topContentView?.removeAllSubviews()
    }

    // MARK: - Private methods

    private func setupUI() {
        add(acWireframe.viewController, to: view)
    }
}
