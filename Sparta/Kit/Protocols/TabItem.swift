//
//  TabItem.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.02.2022.
//

import UIKit
import NetworkingModels

protocol TabItem: DisplayableItem {
    associatedtype Controller: UIViewController
    var controller: Controller { get }
}
