//
//  ArbProfileCategory.swift
//  
//
//  Created by Yaroslav Babalich on 30.09.2021.
//

import UIKit.UIColor
import Foundation
import SwiftyJSON
import SpartaHelpers

public struct ArbProfileCategory: ListableItem {

    //
    // MARK: - Public properties

    public let portfolio: Arb.Portfolio
    public var arbs: [Arb]

    // MARK: - Listable Item

    public var identifier: Int { portfolio.id }
    public var title: String { portfolio.name }

    //
    // MARK: - Default Initializers

    public init(portfolio: Arb.Portfolio) {
        self.portfolio = portfolio
        arbs = []
    }

    // MARK: - Public methods

    public func contains(arb: Arb) -> Bool {
        arbs.contains(arb)
    }
}

extension ArbProfileCategory: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.portfolio == rhs.portfolio
    }
}
