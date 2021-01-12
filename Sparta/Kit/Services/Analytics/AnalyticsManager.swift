//
//  AnalyticsManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.01.2021.
//

import Foundation
import NetworkingModels
import Segment
import Segment_Amplitude
import App

class AnalyticsManager {

    // MARK: - Singleton

    static let intance = AnalyticsManager()

    // MARK: - Private variables

    private var analytics: Analytics { Analytics.shared() }

    // MARK: - Public methods

    func start() {
        let configuration = AnalyticsConfiguration(writeKey: Environment.segmentAPIKey)
        // Enable this to record certain application events automatically!
        configuration.trackApplicationLifecycleEvents = false
        // Enable this to record screen views automatically!
        configuration.recordScreenViews = true

        configuration.use(SEGAmplitudeIntegrationFactory.instance())

        Analytics.setup(with: configuration)
    }

    func track(_ track: AnalyticsTrack) {
        analytics.track(track.name.trackServerName, properties: track.parameters)

        print("***Analytics: Track: \(track.name.trackServerName), parameters: \(track.parameters)")
    }

    func identity(_ user: User) {

        let parameters: Parameters = ["username": user.username ?? "",
                                      "email": user.email,
                                      "environment": Environment.environment.rawValue]

        analytics.identify(user.id.toString, traits: parameters)

        print("***Analytics: Identity: \(user.id.toString), traits: \(parameters)")
    }
}
