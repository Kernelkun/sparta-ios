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

    public let region: BlenderRegion
    public var blenders: [Blender]

    // MARK: - Listable Item

    public var identifier: Int { region.id }
    public var title: String { region.name }

    //
    // MARK: - Default Initializers

    public init(region: BlenderRegion) {
        self.region = region
        blenders = []
    }

    // MARK: - Public methods

    public func contains(blender: Blender) -> Bool {
        blenders.contains(blender)
    }
}

extension BlenderProfileCategory: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.region.id == rhs.region.id
    }
}
