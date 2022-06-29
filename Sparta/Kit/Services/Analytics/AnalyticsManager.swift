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
import Datadog

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

        // setup data dog service

        setupDatadogService()
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

    // MARK: - Private methods

    private func setupDatadogService() {
        let validEnvironments: [Environment.EnvironmentType] = [.stage, .dev]

        guard validEnvironments.contains(Environment.environment) else { return }

        let appID = "0f0ea7f7-5b06-44cd-8c5d-56eaa2f85d63"
        let clientToken = "pub438b388561a0dd7051ed033654a408c3"
        let environment = "staging"

        Datadog.initialize(
            appContext: .init(),
            trackingConsent: .granted,
            configuration: Datadog.Configuration
                .builderUsing(
                    rumApplicationID: appID,
                    clientToken: clientToken,
                    environment: environment
                )
                .set(endpoint: .eu1)
                .trackUIKitRUMViews()
                .trackUIKitRUMActions()
                .trackRUMLongTasks()
                .build()
        )

        Global.rum = RUMMonitor.initialize()
    }
}
