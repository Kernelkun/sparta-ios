//
//  SyncService.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import Foundation
import NetworkingModels
import SpartaHelpers
import Networking

protocol SyncServiceDelegate: class {
    func syncServiceDidFinishSyncInitialData()
}

class SyncService {

    //
    // MARK: - Public properties

    var isInitialDataSynced: Bool {
        phonePrefixes != nil
            && currentUser != nil
            && userRoles != nil
            && tradeAreas != nil
            && freightPorts != nil
    }

    var userRoles: [UserRole]?
    var tradeAreas: [TradeArea]?
    var phonePrefixes: [PhonePrefix]?
    var freightPorts: [FreightPort]?
    var currentUser: User?

    weak var delegate: SyncServiceDelegate?

    //
    // MARK: - Private properties

    private let profileNetworkManager = ProfileNetworkManager()
    private let analyticsNetworkManager = AnalyticsNetworkManager()

    // MARK: - Public methods

    func syncInitialData() {

        var tradeAreas: [TradeArea] = []
        var userRoles: [UserRole] = []
        var prefixes: [PhonePrefix] = []
        var freightPorts: [FreightPort] = []
        var user: User?

        let group = DispatchGroup()

        group.enter()
        profileNetworkManager.fetchPhonePrefixes { result in

            switch result {
            case .success(let responseModel) where responseModel.model != nil:
                prefixes = responseModel.model?.list ?? []

            case .failure, .success:
                prefixes = []
            }

            group.leave()
        }

        group.enter()
        profileNetworkManager.fetchProfile { result in

            switch result {
            case .success(let responseModel) where responseModel.model != nil:
                user = responseModel.model! //swiftlint:disable:this force_unwrapping

            default:
                break
            }

            group.leave()
        }

        group.enter()
        profileNetworkManager.fetchPrimaryTradeAreas { result in

            switch result {
            case .success(let responseModel) where responseModel.model != nil:
                tradeAreas = responseModel.model!.list //swiftlint:disable:this force_unwrapping

            default:
                tradeAreas = []
            }

            group.leave()
        }

        group.enter()
        profileNetworkManager.fetchUserRoles { result in

            switch result {
            case .success(let responseModel) where responseModel.model != nil:
                userRoles = responseModel.model!.list //swiftlint:disable:this force_unwrapping

            default:
                userRoles = []
            }

            group.leave()
        }

        // analytics

        group.enter()
        analyticsNetworkManager.fetchFreightPorts { result in

            switch result {
            case .success(let responseModel) where responseModel.model != nil:
                freightPorts = responseModel.model!.list //swiftlint:disable:this force_unwrapping

            default:
                userRoles = []
            }

            group.leave()
        }

        group.notify(queue: .global(qos: .default)) {
            self.phonePrefixes = prefixes
            self.currentUser = user
            self.tradeAreas = tradeAreas
            self.userRoles = userRoles
            self.freightPorts = freightPorts

            onMainThread {
                self.delegate?.syncServiceDidFinishSyncInitialData()
            }
        }
    }
}
