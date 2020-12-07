//
//  BlenderMonthInfoModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.12.2020.
//

import UIKit

struct BlenderMonthInfoModel {

    // MARK: - Public properties

    let numberPoint: PointModel
    var seasonalityPoint: PointModel? = nil
}

extension BlenderMonthInfoModel {

    struct PointModel {

        // MARK: - Public properties

        let text: String
        let textColor: UIColor
    }
}
