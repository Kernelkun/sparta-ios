//
//  UIAlertFactory.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.06.2021.
//

import UIKit
import SpartaHelpers

enum UIAlertFactory {

    static func showLCPortfoliosLimitReached(in controller: UIViewController) {
        Alert.showOk(title: "Limit Reached",
                     message: """
                        You have reached the limit for the number of products per portfolio.
                        Please remove a product or create a new portfolio.
                        """,
                     show: controller,
                     completion: nil)
    }
}
