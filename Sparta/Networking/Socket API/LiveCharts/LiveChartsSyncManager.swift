//
//  LiveChartsSyncManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.02.2022.
//

import Foundation
import SwiftyJSON
import App
import Networking
import NetworkingModels
import SpartaHelpers

protocol LiveChartsSyncManagerDelegate: AnyObject {
    func liveChartsSyncManagerDidReceive(highlight: LiveChartHighlightSocket)
}

class LiveChartsSyncManager {

    // MARK: - Public properties

    weak var delegate: LiveChartsSyncManagerDelegate?

    // MARK: - Public methods

    func startObserving(
        itemCode: String,
        tenorName: String,
        resolutions: [Environment.LiveChart.Resolution] = Environment.LiveChart.Resolution.allCases
    ) {
        observeSocket(for: .liveCharts(
            itemCode: itemCode,
            tenorName: tenorName,
            resolution: resolutions
        ))

        App.instance.socketsConnect(toServer: .liveCharts(
            itemCode: itemCode,
            tenorName: tenorName,
            resolution: resolutions
        ))
    }

    func stopObserving() {
        stopObservingAllSocketServers()
    }
}

extension LiveChartsSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {
        let liveChartSocket = LiveChartSocket(json: data)

        // check if app received price update

        guard liveChartSocket.socketType == .aggregated else { return }

        let lCHighlightSocket = LiveChartHighlightSocket(json: liveChartSocket.payload)

        onMainThread {
            self.delegate?.liveChartsSyncManagerDidReceive(highlight: lCHighlightSocket)
        }
    }
}
