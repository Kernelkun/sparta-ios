//
//  ArbsVChildACViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2021.
//

import UIKit

class ArbsVChildACViewController: ArbsVChildViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func arbsVContentControllerDidChangeScrollState(
        _ controller: ArbsVContentControllerInterface,
        newState: State
    ) {
        super.arbsVContentControllerDidChangeScrollState(controller, newState: newState)

        let height = newState.height()
        let transitionProgress = newState.transitionProgress()

        parrentController.airBar.applyState(isMinimized: transitionProgress < 1)
    }

    // MARK: - Private methods

    private func setupUI() {

    }
}
