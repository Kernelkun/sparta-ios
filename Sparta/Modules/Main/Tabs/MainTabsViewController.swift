//
//  MainTabsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

class MainTabsViewController: UITabBarController {

    // MARK: - Private properties

    private let viewModel = MainTabsViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let setTabBarItem = { (vc: UIViewController, title: String, imageName: String) in

            vc.title = title//.localized
            vc.tabBarItem.title = vc.title

            vc.tabBarItem.image = UIImage(named: imageName)
        }

        var tabs: [KeyedNavigationController<Tab>] = []

        if viewModel.isVisibleLivePricesBlock {
            let first = LiveCurvesViewController()
            setTabBarItem(first, "MainTabsPage.LiveCurves.Title".localized, "ic_tab_second")

            let navigation = KeyedNavigationController<Tab>(rootViewController: first)
            navigation.setKey(.liveCurves)

            tabs.append(navigation)
        }

        if viewModel.isVisibleArbsBlock {
            let second = ArbsViewController()
            setTabBarItem(second, "MainTabsPage.ARBs.Title".localized, "ic_tab_first")

            let navigation = KeyedNavigationController<Tab>(rootViewController: second)
            navigation.setKey(.arbs)

            tabs.append(navigation)
        }

        if viewModel.isVisibleBlenderBlock {
            let third = BlenderViewController()
            setTabBarItem(third, "MainTabsPage.Blender.Title".localized, "ic_tab_third")

            let navigation = KeyedNavigationController<Tab>(rootViewController: third)
            navigation.setKey(.blender)

            tabs.append(navigation)
        }

        if viewModel.isVisibleFreightBlock {
            let fourth = FreightViewController()
            setTabBarItem(fourth, "MainTabsPage.Freight.Title".localized, "ic_tab_fourth")

            let navigation = KeyedNavigationController<Tab>(rootViewController: fourth)
            navigation.setKey(.freight)

            tabs.append(navigation)
        }

        let fifth = SettingsViewController()
        setTabBarItem(fifth, "MainTabsPage.Settings.Title".localized, "ic_tab_fifth")

        let navigation = KeyedNavigationController<Tab>(rootViewController: fifth)
        navigation.setKey(.settings)

        tabs.append(navigation)

        tabBar.isTranslucent = false

        viewControllers = tabs

        // style

        UITabBar.appearance().tintColor = .tabBarTintActive
        UITabBar.appearance().unselectedItemTintColor = .tabBarTintInactive
        UITabBar.appearance().barTintColor = .barBackground
    }
}

extension MainTabsViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let oldNavigation = tabBarController.selectedViewController as? KeyedNavigationController<Tab>,
           let selectedNavigation = viewController as? KeyedNavigationController<Tab>,
           oldNavigation != selectedNavigation {

            viewModel.sendAnalyticsEventMenuClicked(from: oldNavigation.key?.analyticsName ?? "",
                                                    to: selectedNavigation.key?.analyticsName ?? "")
        }

        return true
    }
}

extension MainTabsViewController {

    fileprivate enum Tab: Hashable {
        case arbs
        case liveCurves
        case blender
        case freight
        case settings

        var analyticsName: String {
            switch self {
            case .arbs:
                return "arbs"

            case .liveCurves:
                return "live curves"

            case .blender:
                return "blender"

            case .freight:
                return "freight"

            case .settings:
                return "settings"
            }
        }
    }
}
