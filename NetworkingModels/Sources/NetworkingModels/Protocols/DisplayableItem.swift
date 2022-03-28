//
//  DisplayableItem.swift
//  
//
//  Created by Yaroslav Babalich on 10.02.2022.
//

import Foundation

public protocol DisplayableItem {
    var title: String { get }
    var longTitle: String { get }
}

public extension DisplayableItem {
    var longTitle: String { title }
}
