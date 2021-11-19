//
//  BlenderProfileCategory.swift
//  
//
//  Created by Yaroslav Babalich on 05.07.2021.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON
import SpartaHelpers

public struct BlenderProfileCategory: ListableItem {

    //
    // MARK: - Public properties

    public let portfolio: Blender.Portfolio
    public var blenders: [Blender]

    // MARK: - Listable Item

    public var identifier: Int { portfolio.id }
    public var title: String { portfolio.name }

    //
    // MARK: - Default Initializers

    public init(portfolio: Blender.Portfolio) {
        self.portfolio = portfolio
        blenders = []
    }

    // MARK: - Public methods

    public func contains(blender: Blender) -> Bool {
        blenders.contains(blender)
    }
}

extension BlenderProfileCategory: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.portfolio == rhs.portfolio
    }
}
