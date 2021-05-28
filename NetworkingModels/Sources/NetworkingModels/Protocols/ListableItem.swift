//
//  ListableItem.swift
//  
//
//  Created by Yaroslav Babalich on 27.05.2021.
//

import Foundation

public protocol ListableItem: IdentifiableItem {
    var title: String { get }
}
