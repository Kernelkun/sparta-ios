//
//  GridViewLayoutAttributes.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 22.12.2020.
//

import UIKit

class GridViewLayoutAttributes: UICollectionViewLayoutAttributes {

    // MARK: - Public properties

    var backgroundColor: UIColor = .red

    override func copy(with zone: NSZone? = nil) -> Any {
        let layout = super.copy(with: zone) as! GridViewLayoutAttributes //swiftlint:disable:this force_cast
        layout.backgroundColor = backgroundColor
        return layout
    }
}
