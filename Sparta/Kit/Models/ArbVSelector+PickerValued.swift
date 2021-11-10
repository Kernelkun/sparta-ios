//
//  ArbVSelector+PickerValued.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.11.2021.
//

import Foundation
import NetworkingModels

extension ArbV.Selector: PickerValued {

    //
    // MARK: - PickerValued

    public var title: String {
        gradeName
    }

    public var fullTitle: String {
        gradeName
    }
}
