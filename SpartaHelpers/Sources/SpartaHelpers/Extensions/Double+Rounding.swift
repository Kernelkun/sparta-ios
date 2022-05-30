//
//  Double+Rounding.swift
//  
//
//  Created by Yaroslav Babalich on 26.10.2021.
//

import Foundation

public extension Double {
    func round(nearest: Double, rule: FloatingPointRoundingRule) -> Double {
        let n = 1 / nearest
        let numberToRound = self * n
        return numberToRound.rounded(rule) / n
    }

    func round(nearest: Double) -> Double {
        let n = 1 / nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }

    func floor(nearest: Double) -> Double {
        let intDiv = Double(Int(self / nearest))
        return intDiv * nearest
    }
}
