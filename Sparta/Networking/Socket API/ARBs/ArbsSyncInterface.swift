//
//  ArbsSyncInterface.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.11.2021.
//

import Foundation
import NetworkingModels

protocol ArbsSyncInterface {
    /// Last date when manager received any updates
    var lastSyncDate: Date? { get }

    /*/// Current live curves
    var liveCurves: [LiveCurve] { get }

    /// Current live curves matched with selected profile
    var profileLiveCurves: [LiveCurve] { get }*/

    /// Current selected portfolio
    var portfolio: ArbProfileCategory? { get }

    /// Profiles list
    var portfolios: [ArbProfileCategory] { get }

    /// HOU months count
    var houMonthsCount: Int { get }

    /// Launch service. To receive any updates need to use this method
    func start()

    /// Change portfolio setting
    func setPortfolio(_ portfolio: ArbProfileCategory)

    /// Update user target to ArbMonth
    func updateUserTarget(_ userTarget: Double, for arbMonth: ArbMonth)

    /// Delete user target to ArbMonth
    func deleteUserTarget(for arbMonth: ArbMonth)

    /*
     * Solution just for UI elements
     * Use when element wanted to fetch latest state of arb
     * In case method not found element in fetched elements array - method will return received(parameter variable) value
     */
    func fetchUpdatedState(for arb: Arb) -> Arb

    /*/// Change profiles order
    func changeProfilesOrder(_ profiles: [LiveCurveProfileCategory])*/
}
