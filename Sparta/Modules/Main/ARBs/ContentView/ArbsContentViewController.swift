//
//  ArbsPContentViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.10.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class ArbsContentViewController: BaseViewController {

    // MARK: - Private properties

    private var contentScrollView: UIScrollView!
    private var mainStackView: UIStackView!
    private var mainContentView: UIView!

    private var contentView: UIView!
    private var menuView: ArbsMenuView!

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {
        menuView = ArbsMenuView(items: ArbsMenuView.MenuItem.allCases).then { view in

            view.onSelect { [unowned self] menuItem in
                setupViewState(for: menuItem)
            }

            addSubview(view) {
                $0.top.equalTo(self.view.snp_topMargin)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(40)
            }
        }

        contentView = UIView().then { view in

            addSubview(view) {
                $0.left.right.bottom.equalToSuperview()
                $0.top.equalTo(menuView.snp.bottom)
            }
        }

        setupViewState(for: .table)

        setupNavigationUI()
    }

    private func setupTestWireframe() {
        let wireframe = ArbsPlaygroundPCWireframe()
        add(wireframe.viewController, to: mainContentView)
    }

    private func setupViewState(for selectedItem: ArbsMenuView.MenuItem) {
        switch selectedItem {
        case .table:
            self.navigationBar(hide: false)
            InterfaceOrientationUtility.lockOrientation(.portrait, rotateTo: .portrait)

            let arbsViewController = ArbsViewController()
            add(arbsViewController, to: contentView)

            // show tabBar
//            tabBarController?.setTabBarHidden(false, animated: true)
            mainTabsViewController?.setTabBarHidden(false, animated: true)
            
        case .dashboard:
            self.navigationBar(hide: true)
            InterfaceOrientationUtility.lockOrientation(.landscape, rotateTo: .landscapeRight)

            let wireframeVContentWireframe = ArbsVContentWireframe()
            add(wireframeVContentWireframe.viewController, to: contentView)

            // show tabBar
//            tabBarController?.setTabBarHidden(true, animated: true)
            mainTabsViewController?.setTabBarHidden(true, animated: true)
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = nil
        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: "MainTabsPage.ARBs.Title".localized)

        let editButton = UIBarButtonItemFactory.editButton { [unowned self] _ in
            navigationController?.pushViewController(ArbsEditPortfolioItemsViewController(), animated: true)
        }

        navigationItem.rightBarButtonItems = [editButton]
    }
}
