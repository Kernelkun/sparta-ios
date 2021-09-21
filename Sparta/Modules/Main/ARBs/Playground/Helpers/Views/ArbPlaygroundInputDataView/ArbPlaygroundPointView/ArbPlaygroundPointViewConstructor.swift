//
//  ArbPlaygroundPointViewConstructor.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.08.2021.
//

import Foundation
import NetworkingModels

struct ArbPlaygroundPointViewConstructor<T> where T: Numeric, T: Comparable, T: CVarArg {
    let title: String
    let subTitle: String?
    let units: String
    let range: ClosedRange<T>
    let step: T
    let startValue: T
}
