//
//  ArbsVChildPCViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2021.
//

import UIKit

class ArbsVChildPCViewController: ArbsVChildViewController {

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
        let contentView = UIView().then { contentView in

            contentView.backgroundColor = .yellow

            addSubview(contentView) {
                $0.height.equalTo(400)
                $0.edges.equalToSuperview()
            }
        }

        let testView = UIView().then { view in

            view.backgroundColor = .white

            contentView.addSubview(view) {
                $0.size.equalTo(CGSize(width: 100, height: 150))
                $0.left.top.equalToSuperview()
            }
        }
    }
}
