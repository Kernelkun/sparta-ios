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
        newState: State
    ) {
        super.arbsVContentControllerDidChangeScrollState(controller, newState: newState)

        let height = newState.height()
        let transitionProgress = newState.transitionProgress()


//        parrentController.airBar.snp.updateConstraints {
//            $0.height.equalTo(60)
//        }

        parrentController.airBar.applyState(isMinimized: /*transitionProgress < 1*/ true)
    }

    // MARK: - Private methods

    private func setupUI() {
        add(pcWireframe.viewController, to: view)
    }
}
