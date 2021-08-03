//
//  BlenderRegion+Default.swift
//  
//
//  Created by Yaroslav Babalich on 05.07.2021.
//

import Foundation

public extension BlenderRegion {

    static var ara: BlenderRegion {
        var model = Self.empty
        model.id = 1
        model.name = "ARA"
        return model
    }

    static var hou: BlenderRegion {
        var model = Self.empty
        model.id = 4
        model.name = "HOU"
        return model
    }
}
