//
//  LiveCurvesSyncManagerProtocol.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.07.2021.
//

import Foundation
import NetworkingModels

protocol LiveCurvesSyncManagerProtocol {
    /// Notification delegate
    var delegate: LiveCurvesSyncManagerDelegate? { get set }

    /// Last date when manager received any updates
    var lastSyncDate: Date? { get }

    /// Current live curves
    var liveCurves: [LiveCurve] { get }

    /// Current live curves matched with selected profile
    var profileLiveCurves: [LiveCurve] { get }

    /// Current selected profile
    var profile: LiveCurveProfileCategory? { get }

    /// Launch service. To receive any updates need to use this method
    func start()

    /// Change profile setting
    func setProfile(_ profile: LiveCurveProfileCategory)

    /// Add profile to list. This method will not send request to server.
    func addProfile(_ profile: LiveCurveProfileCategory, makeActive: Bool)

    /// Remove specific profile
    func removeProfile(_ profile: LiveCurveProfileCategory)

    /// Change profiles order
    func changeProfilesOrder(_ profiles: [LiveCurveProfileCategory])
}
