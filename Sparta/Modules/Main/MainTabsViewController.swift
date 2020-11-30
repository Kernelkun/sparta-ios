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
//            vc.tabBarItem.image = UIImage(named: imageName)
        }

        let first = TestViewController()
        setTabBarItem(first, "Test", "ic_tab_me")

        /*let second = StatViewController()
        setTabBarItem(second, "Stat", "ic_tab_stat")

        let third = LeaderbordViewController()
        setTabBarItem(third, "Leaderboard", "ic_tab_leaderboard")

        let fourth = MerchantsViewController()
        setTabBarItem(fourth, "Rewards", "ic_tab_merchants")

        let fifth = CouponsViewController()
        setTabBarItem(fifth, "Coupon", "ic_tab_coupon")


        tabBar.isTranslucent = false*/

        //

        viewControllers = [
            UINavigationController(rootViewController: first)
//            UINavigationController(rootViewController: second),
//            UINavigationController(rootViewController: third),
//            UINavigationController(rootViewController: fourth),
//            UINavigationController(rootViewController: fifth)
        ]

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

