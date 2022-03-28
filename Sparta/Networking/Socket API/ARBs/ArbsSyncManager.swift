//
//  ArbsSyncManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.12.2020.
//

import Foundation
import SwiftyJSON
import Networking
import NetworkingModels
import SpartaHelpers

class ArbsSyncManager: ArbsSyncInterface {

    var portfolios: [ArbProfileCategory] {
        _portfolios.arrayValue
    }

    // MARK: - Public properties

    private(set) var lastSyncDate: Date? {
        didSet {
            onMainThread {
                self.notifyObserversAboutDidChangeSyncDate(self.lastSyncDate)
            }
        }
    }

    private(set) var portfolio: ArbProfileCategory?

    public var houMonthsCount: Int {
        guard let currentUser = App.instance.syncService.currentUser else { return 2 }

        return currentUser.houArbMonths
    }

    // MARK: - Private properties

    private var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        operationQueue.qualityOfService = .background
        return operationQueue
    }()

    private var _portfolios = SynchronizedArray<ArbProfileCategory>()

    private let arbsManager = ArbsNetworkManager()

    // MARK: - Initializers

    init() {
        observeSocket(for: .arbs)
    }

    deinit {
        stopObservingAllSocketServers()
    }

    // MARK: - Public methods

    func start() {

        // socket connection

        App.instance.socketsConnect(toServer: .arbs)

        // fetch main data
        
        let group = DispatchGroup()

        var portfolios: [Arb.Portfolio] = []
        var arbs: [Arb] = []

        group.enter()
        arbsManager.fetchArbsPortfolios(request: .init(type: .comparisonByRegion)) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {
                portfolios = list

                strongSelf.arbsManager.fetchArbsTable(request: .init(portfolios: portfolios)) { [weak self] result in
                    guard let strongSelf = self else { return }

                    if case let .success(responseModel) = result,
                       let list = responseModel.model?.list {
                        arbs = list

                        group.leave()
                    } else {
                        group.leave()
                    }
                }
            } else {
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }

            let groupedArbs = Dictionary(grouping: arbs, by: { $0.portfolio.name.lowercased() })

            strongSelf._portfolios = SynchronizedArray<ArbProfileCategory>(portfolios.compactMap { portfolio in
                var category = ArbProfileCategory(portfolio: portfolio)

                let profileName = category.portfolio.name.lowercased()
                if let arbs = groupedArbs[profileName] {
                    category.arbs = arbs
                }

                return category
            })

            if strongSelf.portfolio != nil {
                strongSelf.portfolio = strongSelf._portfolios.first { $0 == strongSelf.portfolio }!
            } else {
                strongSelf.portfolio = strongSelf._portfolios.first.required()
            }

            onMainThread {
                strongSelf.updateArbs(for: strongSelf.portfolio.required())
            }

            strongSelf.lastSyncDate = Date()
        }
    }

    func setPortfolio(_ portfolio: ArbProfileCategory) {
        self.portfolio = portfolio
        updateArbs(for: portfolio)
    }

    /*
     * Solution just for UI elements
     * Use when element wanted to fetch latest state of arb
     * In case method not found element in fetched elements array - method will return received(parameter variable) value
     */
    func fetchUpdatedState(for arb: Arb) -> Arb {
        let indexOfPortfolio = _portfolios.index { $0.arbs.contains(arb) }

        guard let indexOfPortfolio = indexOfPortfolio,
              let indexOfArb = _portfolios[indexOfPortfolio]
                .required().arbs.index(where: { $0.uniqueIdentifier == arb.uniqueIdentifier }) else { return arb }

        return _portfolios[indexOfPortfolio].required().arbs[indexOfArb]
    }

    // MARK: - User TGT

    func updateUserTarget(_ userTarget: Double, for arbMonth: ArbMonth) {
        arbsManager.updateArbUserTarget(userTarget, for: arbMonth) { [weak self] result in
            guard let strongSelf = self, result else { return }

            if let indexOfPortfolio = strongSelf.indexOfPortfolio(for: arbMonth),
               let arbIndex = strongSelf._portfolios[indexOfPortfolio].required().arbs.index(where: { $0.months.contains(arbMonth) }),
               let indexOfMonth = strongSelf._portfolios[indexOfPortfolio].required().arbs[arbIndex].months.firstIndex(of: arbMonth) {

                strongSelf.lastSyncDate = Date()

                strongSelf._portfolios[indexOfPortfolio]!.arbs[arbIndex].months[indexOfMonth].userTarget = userTarget //swiftlint:disable:this force_unwrapping

                strongSelf.notifyObservers(about: strongSelf._portfolios[indexOfPortfolio].required().arbs[arbIndex])

                onMainThread {
                    strongSelf.notifyObserversAboutDidReceiveUpdates(for: strongSelf._portfolios[indexOfPortfolio].required().arbs[arbIndex])
                }
            }
        }
    }
    
    func deleteUserTarget(for arbMonth: ArbMonth) {
        arbsManager.deleteArbUserTarget(for: arbMonth) { [weak self] result in
            guard let strongSelf = self, result else { return }

            if let indexOfPortfolio = strongSelf.indexOfPortfolio(for: arbMonth),
               let arbIndex = strongSelf._portfolios[indexOfPortfolio].required().arbs.firstIndex(where: { $0.months.contains(arbMonth) }),
               let indexOfMonth = strongSelf._portfolios[indexOfPortfolio].required().arbs[arbIndex].months.firstIndex(of: arbMonth) {

                strongSelf.lastSyncDate = Date()

                strongSelf._portfolios[indexOfPortfolio]!.arbs[arbIndex].months[indexOfMonth].userTarget = nil //swiftlint:disable:this force_unwrapping

                strongSelf.notifyObservers(about: strongSelf._portfolios[indexOfPortfolio].required().arbs[arbIndex])

                onMainThread {
                    strongSelf.notifyObserversAboutDidReceiveUpdates(for: strongSelf._portfolios[indexOfPortfolio].required().arbs[arbIndex])
                }
            }
        }
    }

    // MARK: - Private methods

    private func notifyAboutUpdated(arbMonth: ArbMonth) {
        guard let indexOfPortfolio = indexOfPortfolio(for: arbMonth),
              let arbIndex = _portfolios[indexOfPortfolio].required().arbs.firstIndex(where: { $0.months.contains(arbMonth) }),
              let indexOfMonth = _portfolios[indexOfPortfolio].required().arbs[arbIndex].months.firstIndex(of: arbMonth) else { return }

        lastSyncDate = Date()

        _portfolios[indexOfPortfolio]!.arbs[arbIndex].months[indexOfMonth].update(from: arbMonth) //swiftlint:disable:this force_unwrapping

        notifyObservers(about: _portfolios[indexOfPortfolio].required().arbs[arbIndex])

        onMainThread {
            self.notifyObserversAboutDidReceiveUpdates(for: self._portfolios[indexOfPortfolio].required().arbs[arbIndex])
        }
    }

    private func updateArbs(for portfolio: ArbProfileCategory) {
        onMainThread {
            self.notifyObserversAboutDidFetch(arbs: portfolio.arbs,
                                              profiles: self._portfolios.arrayValue,
                                              selectedProfile: portfolio)
        }
    }

    private func indexOfPortfolio(for arbMonth: ArbMonth) -> Int? {
        _portfolios.index { portfolio in
            let indexOfMonth = portfolio.arbs.first(where: { $0.months.contains(arbMonth) })
            return indexOfMonth == nil ? false : true
        }
    }
}

extension ArbsSyncManager: SocketActionObserver {

    func socketDidReceiveResponse(for server: SocketAPI.Server, data: JSON) {
        let arbSocket = ArbSocket(json: data)

        guard arbSocket.socketType == .arbMonth else { return }

        let arbMonth = ArbMonth(json: arbSocket.payload)

        notifyAboutUpdated(arbMonth: arbMonth)
    }
}
