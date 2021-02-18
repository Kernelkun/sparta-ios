//
//  ArbTappableCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 22.01.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

protocol ArbTappableCell {
    func apply(arb: Arb)
    func onTap(completion: @escaping TypeClosure<Arb>)
}
