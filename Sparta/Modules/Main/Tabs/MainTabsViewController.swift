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

//        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let setTabBarItem = { (vc: UIViewController, title: String, imageName: String) in

            vc.title = title//.localized
            vc.tabBarItem.title = vc.title

//            let configuration = UIImage.SymbolConfiguration(weight: .bold)
            vc.tabBarItem.image = UIImage(named: imageName)
        }

        var tabs: [UINavigationController] = []

        if viewModel.isVisibleArbsBlock {
            let first = ArbsViewController()
            setTabBarItem(first, "ARBs", "ic_tab_first")

            tabs.append(UINavigationController(rootViewController: first))
        }

        let second = LiveCurvesViewController()
        setTabBarItem(second, "Live Curves", "ic_tab_second")
        tabs.append(UINavigationController(rootViewController: second))

        if viewModel.isVisibleBlenderBlock {
            let third = BlenderViewController()
            setTabBarItem(third, "Blender", "ic_tab_third")

            tabs.append(UINavigationController(rootViewController: third))
        }

        if viewModel.isVisibleFreightBlock {
            let fourth = FreightViewController()
            setTabBarItem(fourth, "Freight", "ic_tab_fourth")

            tabs.append(UINavigationController(rootViewController: fourth))
        }

        let fifth = SettingsViewController()
        setTabBarItem(fifth, "Settings", "ic_tab_fifth")
        tabs.append(UINavigationController(rootViewController: fifth))

        tabBar.isTranslucent = false

        viewControllers = tabs

        // style

        UITabBar.appearance().tintColor = .tabBarTintActive
        UITabBar.appearance().unselectedItemTintColor = .tabBarTintInactive
        UITabBar.appearance().barTintColor = .barBackground

//        if let navC = selectedViewController as? UINavigationController {
//            Router.instance.navigationViewController = navC
//        }
    }
}

/*extension MainTabsViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navC = viewController as? UINavigationController {
            Router.instance.navigationViewController = navC
        }
    }
}*/
