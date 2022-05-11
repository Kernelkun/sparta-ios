//
//  ArbsVChildPCViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2021.
//

import UIKit

class ArbsVChildPCViewController: ArbsVChildViewController {

    // MARK: - Private properties

    private lazy var pcWireframe = ArbsPlaygroundPCWireframe(actionsDelegate: self)

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
//        parrentController.airBar.topRightContentView.backgroundColor = .red
    }

    override func arbsVContentControllerDidChangePage(
        _ controller: ArbsVContentControllerInterface,
        newPage: ArbsVContentPage
    ) {
        super.arbsVContentControllerDidChangePage(controller, newPage: newPage)

        guard newPage == .pricingCenter else { return }

        parrentController.airBar.applyState(isMinimized: true)

        parrentController.airBar.snp.updateConstraints {
            $0.height.equalTo(55)
        }

        let topContentView = parrentController.airBar.topRightContentView
        topContentView?.removeAllSubviews()
        topContentView?.addSubview(pcWireframe.viewController.airBarTopMenu) {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .clear
        add(pcWireframe.viewController, to: view)
    }
}

extension ArbsVChildPCViewController: ArbsPlaygroundPCActionDelegate {

    func arbsPlaygroundPCViewControllerDidChangeContentOffset(_ viewController: ArbsPlaygroundPCViewController, offset: CGFloat, direction: MovingDirection) {
        var currentOffset = parrentController.contentScrollView.contentOffset.y

        if direction == .up {
            currentOffset += offset
        } else {
            currentOffset -= offset
        }

        parrentController.contentScrollView.contentOffset = CGPoint(x: 0, y: currentOffset)

        if parrentController.contentScrollView.contentSize.height < currentOffset {
        }
    }
}
