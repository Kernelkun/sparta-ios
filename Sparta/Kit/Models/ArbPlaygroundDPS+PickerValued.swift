//
//  ArbPlaygroundDPS+PickerValued.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.08.2021.
//

import Foundation
import NetworkingModels

extension ArbPlaygroundDPS: PickerValued {

    //
    // MARK: - PickerValued

    public var title: String {
        monthName
    }

    public var fullTitle: String {
        monthName
    }
}
