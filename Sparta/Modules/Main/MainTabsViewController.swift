//
//  MainTabsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

class MainTabsViewController: UITabBarController {

    // MARK: - Variables private

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

        let first = TestViewController()
        setTabBarItem(first, "ARBs", "ic_tab_first")

        let second = TestViewController()
        setTabBarItem(second, "Blender", "ic_tab_second")

        let third = TestViewController()
        setTabBarItem(third, "Freight calculator", "ic_tab_third")

        let fourth = TestViewController()
        setTabBarItem(fourth, "Settings", "ic_tab_fourth")


        tabBar.isTranslucent = false

        //

        viewControllers = [
            UINavigationController(rootViewController: first),
            UINavigationController(rootViewController: second),
            UINavigationController(rootViewController: third),
            UINavigationController(rootViewController: fourth)
        ]

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
