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

            //Show tabBar
            tabBarController?.setTabBarHidden(false, animated: true)
            
        case .dashboard:
            self.navigationBar(hide: true)
            InterfaceOrientationUtility.lockOrientation(.landscape, rotateTo: .landscapeRight)

            let arbsViewController = ArbsVContentViewController()
            add(arbsViewController, to: contentView)

            //Hide tabBar
            tabBarController?.setTabBarHidden(true, animated: true)
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

extension UITabBarController {
    /// Extends the size of the `UITabBarController` view frame, pushing the tab bar controller off screen.
    /// - Parameters:
    ///   - hidden: Hide or Show the `UITabBar`
    ///   - animated: Animate the change
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        guard let vc = selectedViewController else { return }
        guard tabBarHidden != hidden else { return }

        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = hidden ? height : -height

        UIViewPropertyAnimator(duration: animated ? 0.3 : 0, curve: .easeOut) {
            self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
            self.selectedViewController?.view.frame = CGRect(
                x: 0,
                y: 0,
                width: vc.view.frame.width,
                height: vc.view.frame.height + offsetY
            )

            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }
        .startAnimation()
    }

    /// Is the tab bar currently off the screen.
    private var tabBarHidden: Bool {
        tabBar.frame.origin.y >= UIScreen.main.bounds.height
    }
}
