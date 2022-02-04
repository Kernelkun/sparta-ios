//
//  Blender+UIType.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.01.2022.
//

import NetworkingModels

extension Blender {
    var isParrent: Bool { type == .normal || type == .regrade || type == .userCustom }
    var isChild: Bool { type == .counterSesonality }
}
