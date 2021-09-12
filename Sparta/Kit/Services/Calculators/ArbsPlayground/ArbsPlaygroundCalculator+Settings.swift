//
//  ArbsPlaygroundCalculator+ArbPlayground.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.09.2021.
//

import Foundation
import NetworkingModels

extension ArbsPlaygroundCalculator {

    class Settings {

        // MARK: - Public properties

        var arbPlayground: ArbPlayground?
        var arbPlaygroundMonth: ArbPlaygroundMonth?
        var deliveredPriceSpreadsMonth: ArbPlaygroundDPS?
        var visibleDeliveredPriceSpreadsMonth: [ArbPlaygroundDPS] = []

        // MARK: - Private properties

        private var _initialArbPlayground: ArbPlayground?

        // MARK: - Public methods

        func applyArbPlayground(_ arbPlayground: ArbPlayground) {
            self.arbPlayground = arbPlayground
            self._initialArbPlayground = arbPlayground
            applyArbPlaygroundMonth(arbPlayground.months.first!)
            roundValuesForCalculation(&arbPlaygroundMonth!)
        }

        func applyArbPlaygroundMonth(_ arbPlaygroundMonth: ArbPlaygroundMonth) {
            self.arbPlaygroundMonth = arbPlaygroundMonth
            applyDefaultDeliveredPriceSpreadsMonthSettings(for: self.arbPlaygroundMonth!)
        }

        func applyArbDeliveredPriceSpreadsMonth(_ deliveredPriceSpreadsMonth: ArbPlaygroundDPS) {
            self.deliveredPriceSpreadsMonth = deliveredPriceSpreadsMonth
        }

        private func roundValuesForCalculation(_ month: inout ArbPlaygroundMonth) {
            month.blendCost.value = month.blendCost.value?.round(nearest: 0.25)
            month.naphtha.value = month.naphtha.value.round(nearest: 0.25)
            month.naphtha.pricingComponentsVolume = month.naphtha.pricingComponentsVolume.round(nearest: 1)
            month.taArb.value = month.taArb.value?.round(nearest: 0.05)
            month.ew.value = month.ew.value?.round(nearest: 0.05)

            if month.freight.units.lowercased() == "ls" {
                month.freight.value = month.freight.value?.round(nearest: 5_000)
            } else {
                month.freight.value = month.freight.value?.round(nearest: 1)
            }
        }

        private func applyDefaultDeliveredPriceSpreadsMonthSettings(for arbPlaygroundMonth: ArbPlaygroundMonth) {
            guard let arbPlayground = _initialArbPlayground,
                  var deliveredPriceSpreadsMonthIndex = arbPlayground.deliveredPriceSpreads
                    .firstIndex(where: { $0.monthName == arbPlaygroundMonth.defaultSpreadMonthName })
//                  let currentMonthIndex = arbPlayground.deliveredPriceSpreads
//                    .firstIndex(where: { $0.monthName == arbPlaygroundMonth.monthName })
                  else { return }

            // months

            var finalMonthsSteps = 4

//            if deliveredPriceSpreadsMonthIndex != currentMonthIndex {
//                deliveredPriceSpreadsMonthIndex -= 1
//                finalMonthsSteps = 5
//            }

            let finalIndex = deliveredPriceSpreadsMonthIndex + finalMonthsSteps
            if finalIndex < arbPlayground.deliveredPriceSpreads.count {
                self.visibleDeliveredPriceSpreadsMonth = Array(arbPlayground.deliveredPriceSpreads[deliveredPriceSpreadsMonthIndex...deliveredPriceSpreadsMonthIndex + finalMonthsSteps])
            } else {
                self.visibleDeliveredPriceSpreadsMonth = Array(arbPlayground.deliveredPriceSpreads[deliveredPriceSpreadsMonthIndex...])
            }

            self.deliveredPriceSpreadsMonth = arbPlayground.deliveredPriceSpreads[deliveredPriceSpreadsMonthIndex]
        }
    }
}
