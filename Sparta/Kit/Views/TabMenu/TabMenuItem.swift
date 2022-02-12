//
//  TabMenuItem.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.02.2022.
//

import UIKit

class TabMenuItem: TabItem {

    // MARK: - Public propreties

    let title: String
    let longTitle: String
    let imageName: String
    let controller: UIViewController

    // MARK: - Initializers

    init(title: String, imageName: String, controller: UIViewController) {
        self.title = title
        self.longTitle = title
        self.imageName = imageName
        self.controller = controller
    }
}

extension TabMenuItem: Equatable {

    static func == (lhs: TabMenuItem, rhs: TabMenuItem) -> Bool {
        lhs.title == rhs.title
    }
}
