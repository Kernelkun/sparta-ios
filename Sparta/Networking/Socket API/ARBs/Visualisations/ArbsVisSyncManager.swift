//
//  ArbsVisSyncManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.03.2022.
//

import Foundation
import SwiftyJSON
import App
import Networking
import NetworkingModels
import SpartaHelpers

class ArbsVisSyncManager: ArbsVisSyncInterface {

    // MARK: - Initializers

    deinit {
        stopObservingAllSocketServers()
    }

    // MARK: - Public methods

    func start(dateRange: Environment.Visualisations.DateRange) {
        observeSocket(for: .visualisations(dateRange: dateRange))
        App.instance.socketsConnect(toServer: .visualisations(dateRange: dateRange))
    }
}

// by semidicate
/*{"payload":{"arbId":143,"deliveryMonth":"Mar 22","deliveryWindow":"26-EOM","generatedOn":"2022-03-25T13:46:32Z","blendCost":-24.15,"gasNaphtha":null,"freight":345000,"taArb":null,"ew":null,"genBlenderMargin":null,"isOpen":null},"type":"chartarbs"}    1648235393.776403 //swiftlint:disable:this line_length


{"payload":{"arbId":126,"loadMonth":"Aug 22","loadWindow":"16-20","deliveryMonth":"Sep 22","deliveryWindow":"1-5","deliveredPrice":{"value":56.25,"displayedValue":"+56.25"},"margins":[{"type":"Blender Mrg","value":null,"displayedValue":null,"color":null},{"type":"ARA Ref Mrg","value":null,"displayedValue":null,"color":null},{"type":"NWE Ref Mrg","value":null,"displayedValue":null,"color":null}]},"type":"arbmonth"}    1648235390.5753286 //swiftlint:disable:this line_length

{"payload":{"arbId":126,"deliveryMonth":"Sep 22","deliveryWindow":"1-5","generatedOn":"2022-03-25T13:46:32Z","deliveredPrice":56.25,"genBlenderMargin":null},"type":"charthistorical"}    1648235390.5772016*/ //swiftlint:disable:this line_length

// by month

extension ArbsVisSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {
        let arbVSocket = ArbVSocket(json: data)

        if arbVSocket.socketType == .arbmonth {
            let arbVMonth = ArbVMonthSocket(json: arbVSocket.payload)

            onMainThread {
                self.notifyObservers(about: arbVMonth)
            }

            return
        }
    }
}
